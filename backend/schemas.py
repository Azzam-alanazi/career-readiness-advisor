"""Request and response shapes."""
from pydantic import BaseModel, Field


class ValidationInfo(BaseModel):
    """Travels with every readiness figure, so the client can qualify it."""
    gate_passed: bool
    best_f1: float | None
    gate_min_f1: float | None
    course_mapping_validated: bool
    note: str


class CareerOut(BaseModel):
    name: str
    posting_count: int


class CourseOut(BaseModel):
    code: str
    name: str
    skill_count: int


class ProfileIn(BaseModel):
    career: str
    completed_courses: list[str] = Field(default_factory=list,
                                         description="Course codes from GET /courses")
    major: str | None = None


class ProfileOut(BaseModel):
    id: str
    career: str
    major: str | None
    completed_courses: list[str]
    created_at: str


class SkillEntry(BaseModel):
    id: str
    en: str
    ar: str
    category: str
    demand: float = Field(description="Fraction of this career's postings requiring it")
    demand_percent: int


class GapOut(BaseModel):
    profile_id: str
    career: str
    readiness: float = Field(description="Demand-weighted share of required skills held")
    readiness_percent: int
    covered: list[SkillEntry]
    missing: list[SkillEntry] = Field(description="Ranked by demand, highest first")
    validation: ValidationInfo


class SkillRef(BaseModel):
    id: str
    en: str
    ar: str
    demand_percent: int


class RecommendationOut(BaseModel):
    code: str
    name: str
    closes: list[SkillRef]
    value: float = Field(description="Total demand of the gaps this course closes")


class RecommendationsOut(BaseModel):
    profile_id: str
    career: str
    recommendations: list[RecommendationOut]
    validation: ValidationInfo


class HealthOut(BaseModel):
    status: str
    model: str
    taxonomy_skills: int
    careers: int
    courses: int
    built_from_cache: bool
    validation: ValidationInfo
