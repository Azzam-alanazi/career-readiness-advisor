"""Shared fixtures. The fixture world itself lives in world.py."""
import pytest

from backend.tests.world import FakeEmbedder, write_world


@pytest.fixture
def embedder():
    FakeEmbedder.instances = 0
    return FakeEmbedder


@pytest.fixture
def world(tmp_path):
    return write_world(tmp_path / "world")


@pytest.fixture
def make_client(world, embedder):
    from fastapi.testclient import TestClient

    from backend.engine import build_state
    from backend.main import create_app

    def _make(paths=None):
        app = create_app(state_factory=lambda: build_state(paths or world, embedder))
        return TestClient(app)

    return _make


@pytest.fixture
def client(make_client):
    with make_client() as c:
        yield c
