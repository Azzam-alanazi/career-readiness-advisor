"""Request and response shapes."""
from typing import Annotated, Literal

from pydantic import BaseModel, Field


class ValidationInfo(BaseModel):
    """Travels with every readiness figure, so the client can qualify it."""
    gate_passed: bool
    best_f1: float | None
    gate_min_f1: float | None
    course_mapping_validated: bool = Field(
        description="True only when every course's skills come from hand labels")
    note: str


class CareerOut(BaseModel):
    name: str
    posting_count: int


class CourseOut(BaseModel):
    code: str
    name: str
    skill_count: int
    mapped_by: Literal["labels", "extraction"] = Field(
        description="Hand labels where the course has them, extraction otherwise")


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


class UniversityRecommendation(BaseModel):
    """A course from the university catalog. It counts toward the degree."""
    source: Literal["university"] = "university"
    code: str
    name: str
    closes: list[SkillRef]
    value: float = Field(description="Total demand of the gaps this course closes")


class OnlineRecommendation(BaseModel):
    """
    An online course, offered only for skills no catalog course teaches. It does
    not count toward the degree.
    """
    source: Literal["online"] = "online"
    provider: str
    title: str
    url: str
    is_free: bool
    closes: list[SkillRef]
    value: float = Field(description="Total demand of the gaps this course closes")


Recommendation = Annotated[UniversityRecommendation | OnlineRecommendation,
                           Field(discriminator="source")]


class RecommendationsOut(BaseModel):
    profile_id: str
    career: str
    recommendations: list[Recommendation] = Field(description=(
        "University courses first, then online courses, each ranked by the demand "
        "they close. Every missing skill is closed by at least one of them or is "
        "listed in `uncovered`."))
    uncovered: list[SkillRef] = Field(description=(
        "Missing skills that no university course teaches and no online course is "
        "listed for yet, ranked by demand"))
    validation: ValidationInfo


class HealthOut(BaseModel):
    status: str
    model: str
    taxonomy_skills: int
    careers: int
    courses: int
    online_courses: int = Field(description="Online courses filled in")
    online_placeholders: int = Field(description="Rows still waiting for an online course")
    built_from_cache: bool
    validation: ValidationInfo
