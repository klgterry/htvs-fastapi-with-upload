from fastapi import FastAPI, Request, Form, File, UploadFile
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pathlib import Path
import subprocess
from fastapi.staticfiles import StaticFiles
import json
import psutil
import platform
from fastapi.responses import JSONResponse
import uuid

app = FastAPI()
templates = Jinja2Templates(directory="templates")

@app.get("/results/{run_id}", response_class=HTMLResponse)
async def show_results(request: Request, run_id: str):
    return templates.TemplateResponse("results.html", {
        "request": request,
        "report_file": f"{run_id}/report.html",
        "timeline_file": f"{run_id}/timeline.html"
    })

# 🔻 정적 파일 경로 연결 (HTML 다운로드, iframe용)
app.mount("/results", StaticFiles(directory="results"), name="results")

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse("home.html", {"request": request})


@app.get("/builder")
async def builder_ui(request: Request):
    return templates.TemplateResponse("builder.html", {"request": request})


@app.get("/scaffold", response_class=HTMLResponse)
async def scaffold_page(request: Request):
    return templates.TemplateResponse("scaffold.html", {"request": request})


@app.get("/generation", response_class=HTMLResponse)
async def generation_page(request: Request):
    return templates.TemplateResponse("generation.html", {"request": request})


@app.post("/upload")
async def upload_files(ligand: UploadFile = File(...), protein: UploadFile = File(...)):
    upload_dir = Path("uploads")
    upload_dir.mkdir(exist_ok=True)

    ligand_path = upload_dir / "ligand.sdf"
    protein_path = upload_dir / "protein.pdb"

    with open(ligand_path, "wb") as lf:
        lf.write(await ligand.read())

    with open(protein_path, "wb") as pf:
        pf.write(await protein.read())

    return {"message": "✅ Files uploaded successfully"}

from fastapi import Request, UploadFile, File, Form
from fastapi.responses import JSONResponse
from typing import List, Optional
from pathlib import Path
import subprocess
import json
import os
import sys

def generate_main_nf(modules: list[str], curate_path: str = None, sdf_path: str = None):
    # Header with DSL2 and outdir
    header = "nextflow.enable.dsl=2\n"
    header += "params.outdir = \"./results/${workflow.runName}\"\n\n"

    # Dynamic channels
    channels = []
    if "proteinPrep" in modules and curate_path:
        channels.append(f"curate_dir = Channel.fromPath('{curate_path}')")
    if "dockingSim" in modules and sdf_path:
        channels.append(f"ligand_file = Channel.fromPath('{sdf_path}')")
    channel_block = "\n".join(channels) + "\n\n"

    # Process scripts and workflow steps
    script = ""
    workflow = "workflow {\n"
    if "proteinPrep" in modules:
        script += Path("dynamic_templates/proteinPrep.nf").read_text() + "\n\n"
        workflow += "    proteinPrep()\n"
    if "dockingSim" in modules:
        script += Path("dynamic_templates/dockingSim.nf").read_text() + "\n\n"
        workflow += "    dockingSim()\n"
    if "ranking" in modules:
        script += Path("dynamic_templates/ranking.nf").read_text()
        workflow += "    ranking(docking.dock_out)\n"
    if "scaffoldDelete" in modules:
        script += Path("dynamic_templates/scaffoldDelete.nf").read_text() + "\n\n"
        workflow += "    scaffoldDelete()\n"
    if "reinventLinker" in modules:
        script += Path("dynamic_templates/reinventLinker.nf").read_text() + "\n\n"
        workflow += "    reinventLinker()\n"
    if "reinventDenovo" in modules:
        script += Path("dynamic_templates/reinventDenovo.nf").read_text() + "\n\n"
        workflow += "    reinventDenovo()\n"
    if "reinventMolopt" in modules:
        script += Path("dynamic_templates/reinventMolopt.nf").read_text() + "\n\n"
        workflow += "    reinventMolopt()\n"
    if "reinventScaffold" in modules:
        script += Path("dynamic_templates/reinventScaffold.nf").read_text() + "\n\n"
        workflow += "    reinventScaffold()\n"

    workflow += "}\n\n"

    # Final block: status.json + report/timeline 이동
    on_complete_block = """
workflow.onComplete {
    def outdir = params.outdir
    def json = [
        status: workflow.success ? "DONE" : "FAILED",
        succeeded: workflow.stats.succeededCount,
        failed: workflow.stats.failedCount,
        total: workflow.stats.totalCount
    ]
    new File("${outdir}/status.json").text = groovy.json.JsonOutput.toJson(json)
}
"""

    # Final file write
    Path("main_dynamic.nf").write_text(header + channel_block + script + workflow + on_complete_block)
    os.environ["NXF_DOCKER_OPTS"] = "--gpus 0"

    print("✅ main_dynamic.nf generated.")


    
from fastapi import Form, File, UploadFile, Request
from fastapi.responses import JSONResponse
from typing import Optional, List
from pathlib import Path
import uuid
import json
import subprocess
import os

@app.post("/run")
async def run_pipeline(
    request: Request,
    modules: str = Form(...),
    user_name: Optional[str] = Form("unknown"),
    job_name: Optional[str] = Form("unnamed"),
    use_local: Optional[bool] = Form(False),
    ligand_source: Optional[str] = Form(None),
    protein_path: Optional[str] = Form(None),
    ligand_path: Optional[str] = Form(None),
    ligand_files: Optional[List[UploadFile]] = File(None),
    protein_files: Optional[List[UploadFile]] = File(None)
):
    # Parse module selection
    modules = json.loads(modules)

    # # Create directories
    # ligand_dir = Path(f"uploads/ligands/{ligand_source}")
    # protein_dir = Path("uploads/proteins")
    # ligand_dir.mkdir(parents=True, exist_ok=True)
    # protein_dir.mkdir(parents=True, exist_ok=True)

    # saved_protein_files = []
    # saved_ligand_files = []

    # # Save uploaded protein files
    # if protein_files:
    #     for file in protein_files:
    #         save_path = protein_dir / file.filename
    #         save_path.write_bytes(await file.read())
    #         saved_protein_files.append(save_path)

    # # Save uploaded ligand files
    # if ligand_files:
    #     for file in ligand_files:
    #         save_path = ligand_dir / file.filename
    #         save_path.write_bytes(await file.read())
    #         saved_ligand_files.append(save_path)

    # # Resolve protein path
    # if saved_protein_files:
    #     pdb_path = str(saved_protein_files[0])
    # elif protein_path:
    #     pdb_path = protein_path
    # else:
    #     if "proteinPrep" in modules:
    #         return JSONResponse(status_code=400, content={"success": False, "message": "❌ Protein input is required for proteinPrep"})
    #     pdb_path = None

    # # Resolve ligand path
    # if saved_ligand_files:
    #     sdf_path = str(ligand_dir / "*.sdf")
    # elif ligand_path:
    #     sdf_path = ligand_path
    # else:
    #     if "dockingSim" in modules:
    #         return JSONResponse(status_code=400, content={"success": False, "message": "❌ Ligand input is required for dockingSim"})
    #     sdf_path = None

    # Prepare run_id and result dir
    run_id = f"run_{uuid.uuid4()}"
    result_dir = Path(f"./results/{run_id}")
    result_dir.mkdir(parents=True, exist_ok=True)

    # ✅ 사용자 정보 메타 저장
    (Path(f"./results/{run_id}/metadata.json")).write_text(json.dumps({
        "run_id": run_id,
        "user": user_name,
        "job_name": job_name,
        "use_local": use_local,
        "start_time": time.strftime('%Y-%m-%d %H:%M:%S')
    }))

    # Generate Nextflow script dynamically
    generate_main_nf(
        modules=modules,
        curate_path="/home/klgterry/curate",  # <- adjust if needed
        #sdf_path=sdf_path
    )

    # Run Nextflow as background process with nohup
    nf_command = (
        f"nextflow run main_dynamic.nf "
        f"-with-docker -with-report {result_dir}/report.html -with-timeline {result_dir}/timeline.html "
        f"-name {run_id} > {result_dir}/.nextflow.log 2>&1 &"
    )

    subprocess.Popen(nf_command, shell=True)

    # Immediately respond to frontend
    return JSONResponse({
        "success": True,
        "message": "✅ Pipeline started!",
        "run_id": run_id
    })

def get_gpu_info():
    try:
        output = subprocess.check_output(
            "nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits",
            shell=True
        ).decode("utf-8").strip()

        if not output:
            return "Unavailable"

        lines = output.splitlines()
        results = []
        for idx, line in enumerate(lines):
            parts = line.split(',')
            if len(parts) < 3:
                continue
            gpu_util, mem_used, mem_total = map(str.strip, parts)
            mem_percent = round((float(mem_used) / float(mem_total)) * 100)
            results.append(f"GPU {idx}: {gpu_util}% ({mem_used}/{mem_total} MB, {mem_percent}%)")
        return " | ".join(results) if results else "Unavailable"

    except Exception:
        return "Unavailable"

@app.get("/system/status")
async def system_status():
    cpu_percent = psutil.cpu_percent(interval=0.5)
    cpu_count = psutil.cpu_count()
    mem = psutil.virtual_memory()
    mem_used = round(mem.used / 1024**3, 1)
    mem_total = round(mem.total / 1024**3, 1)

    return {
        "host": platform.node(),
        "cpu_percent": cpu_percent,
        "cpu_count": cpu_count,
        "mem_used": mem_used,
        "mem_total": mem_total,
        "gpu_usage": get_gpu_info()
    }


from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from fastapi import Request
from fastapi import status

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": exc.errors(), "body": str(exc.body)},
    )

import time

@app.get("/dashboard", response_class=HTMLResponse)
def dashboard(request: Request):
    results_path = Path("./results")
    run_dirs = sorted(results_path.glob("run_*"), key=os.path.getctime, reverse=True)
    
    runs = []
    for run_dir in run_dirs:
        status_file = run_dir / "status.json"
        metadata_file = run_dir / "metadata.json"
        run_id = run_dir.name
        info = {
            "run_id": run_id,
            "status": "RUNNING",
            "succeeded": 0,
            "total": 1,
            "start_time": time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(os.path.getctime(run_dir)))
        }

        if status_file.exists():
            try:
                with open(status_file) as f:
                    status_data = json.load(f)
                    info.update(status_data)
            except:
                pass

        # ✅ 사용자 정보 추가
        if metadata_file.exists():
            try:
                with open(metadata_file) as f:
                    meta_data = json.load(f)
                    info.update(meta_data)  # includes: user, job_name, use_local, etc.
            except:
                pass

        runs.append(info)

    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "runs": runs
    })


@app.get("/run_status/{run_id}")
def get_run_status(run_id: str):
    status_file = Path(f"./results/{run_id}/status.json")
    
    if not status_file.exists():
        return {"status": "RUNNING", "succeeded": 0, "total": 1}  # 기본값

    try:
        with open(status_file) as f:
            data = json.load(f)
            return {
                "status": data.get("status", "RUNNING"),
                "succeeded": data.get("succeeded", 0),
                "total": data.get("total", 1)
            }
    except:
        return {"status": "RUNNING", "succeeded": 0, "total": 1}

from fastapi import HTTPException

@app.delete("/delete/{run_id}")
def delete_run(run_id: str):
    run_path = Path(f"./results/{run_id}")
    if run_path.exists() and run_path.is_dir():
        import shutil
        shutil.rmtree(run_path)
        return {"success": True, "message": f"{run_id} 삭제됨"}
    else:
        raise HTTPException(status_code=404, detail="해당 run_id 디렉토리가 존재하지 않습니다.")

@app.get("/recent_runs")
def get_recent_runs(n: int = 3):
    from pathlib import Path
    import os, json

    results_dir = Path("./results")
    runs = []

    for run_dir in sorted(results_dir.glob("run_*"), key=os.path.getmtime, reverse=True)[:n]:
        meta_file = run_dir / "metadata.json"
        if not meta_file.exists():
            continue

        with open(meta_file) as f:
            meta = json.load(f)

        runs.append({
            "run_id": meta.get("run_id", run_dir.name),
            "status": "DONE",  # 또는 별도로 status 저장한 경우 반영
            "user": meta.get("user", "unknown"),
            "job_name": meta.get("job_name", "N/A"),
            "start_time": meta.get("start_time", "N/A")
        })

    return runs
