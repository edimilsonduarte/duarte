from fastapi import FastAPI

app = FastAPI(title="api-python")


@app.get("/health")
def health():
    return {"status": "ok", "service": "api-python"}


@app.get("/")
def root():
    return {"message": "API Python no ar! Adicione suas rotas em apps/api-python/main.py"}
