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
    skills: list[str] = Field(
        description="Skill ids the course teaches, so a client can tell which skills "
                    "a student's courses already cover")
    mapped_by: Literal["labels", "extraction"] = Field(
        description="Hand labels where the course has them, extraction otherwise")
    track: str = Field(
        description="The catalog's track for the course -- college, core, or an elective "
                    "track -- for grouping it on screen; empty when the catalog gives none")


class SkillOut(BaseModel):
    """One taxonomy skill, for choosing self-reported skills."""
    id: str
    en: str
    ar: str
    category: str


class ProfileIn(BaseModel):
    career: str
    completed_courses: list[str] = Field(default_factory=list,
                                         description="Course codes from GET /courses")
    self_reported_skills: list[str] = Field(
        default_factory=list,
        description="Skill ids from GET /skills that the student holds from outside "
                    "coursework: self-study, certifications, work experience. Unverified.")
    other_careers: list[str] = Field(
        default_factory=list, max_length=2,
        description="Up to two more target careers from GET /careers, to compare with "
                    "`career` side by side. Repeats, and `career` itself, are dropped")
    major: str | None = None


class StudentIn(BaseModel):
    """
    A student's profile sent with the request, for a reading that stores
    nothing. The app keeps the profile on the device and sends this each time.
    """
    career: str
    completed_courses: list[str] = Field(default_factory=list,
                                         description="Course codes from GET /courses")
    self_reported_skills: list[str] = Field(
        default_factory=list,
        description="Skill ids from GET /skills held from outside coursework. Unverified.")


class ProfileOut(BaseModel):
    id: str
    career: str
    major: str | None
    completed_courses: list[str]
    self_reported_skills: list[str]
    other_careers: list[str]
    careers: list[str] = Field(
        description="`career` first, then `other_careers`: every career the profile's "
                    "gap and suggestions can be read against")
    created_at: str


class SkillEntry(BaseModel):
    id: str
    en: str
    ar: str
    category: str
    demand: float = Field(description="Fraction of this career's postings requiring it")
    demand_percent: int


class CoveredSkill(SkillEntry):
    """A skill the student has, and where it came from."""
    source: Literal["courses", "self_reported"] = Field(
        description="A skill a completed course teaches is 'courses', even when the "
                    "student also reported it")


class GapOut(BaseModel):
    profile_id: str | None = Field(
        None, description="The stored profile read; null when the profile came with the "
                          "request (POST /gap), which stores nothing")
    career: str
    readiness: float = Field(
        description="Demand-weighted share of required skills held, from courses and "
                    "self-reported skills together")
    readiness_percent: int
    readiness_from_courses: float = Field(
        description="The same share from completed courses alone: the academic record")
    readiness_from_courses_percent: int
    covered: list[CoveredSkill] = Field(
        description="Both sources together, each skill marked with its source")
    covered_from_courses: list[SkillEntry] = Field(
        description="The covered skills that come from completed courses")
    covered_self_reported: list[SkillEntry] = Field(
        description="The covered skills that come only from the student's own report. "
                    "With covered_from_courses it makes up `covered` exactly")
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
    profile_id: str | None = Field(
        None, description="The stored profile read; null when the profile came with the "
                          "request (POST /recommendations), which stores nothing")
    career: str
    recommendations: list[Recommendation] = Field(description=(
        "University courses first, then online courses, each ranked by the demand "
        "they close. Every missing skill is closed by at least one of them or is "
        "listed in `uncovered`."))
    uncovered: list[SkillRef] = Field(description=(
        "Missing skills that no university course teaches and no online course is "
        "listed for yet, ranked by demand"))
    validation: ValidationInfo


class CurriculumSkill(BaseModel):
    """A skill the postings ask for that no catalog course teaches."""
    id: str
    en: str
    ar: str
    category: str
    postings: int = Field(description="Postings in scope that name it")
    demand: float = Field(description="Share of the postings in scope that name it")
    demand_percent: int
    careers: list[str] = Field(description="Careers in scope that count it as demanded")


class TaughtSkill(BaseModel):
    """A skill the catalog teaches that no posting in scope asks for."""
    id: str
    en: str
    ar: str
    category: str
    courses: list[str] = Field(description="Codes of the catalog courses teaching it")


class BelowThresholdSkill(BaseModel):
    """
    Named by some posting in scope, but by too few to count as demanded in any
    career of it -- so in neither the uncovered nor the not-asked list.
    """
    id: str
    en: str
    ar: str
    category: str
    postings: int = Field(description="Postings in scope that name it")
    careers: list[str] = Field(description="Careers in scope whose postings name it")
    courses: list[str] = Field(description="Catalog courses teaching it; empty when none does")


class CareerCoverageOut(BaseModel):
    career: str
    posting_count: int
    demanded: int = Field(description="Skills the career's postings ask for")
    taught: int = Field(description="Of those, the ones at least one course teaches")
    coverage: float
    coverage_percent: int
    min_postings: int = Field(description=(
        "Postings of this career a skill needs to count as demanded at min_demand. "
        "min_demand is a share, so this grows with the career's posting count"))


class CurriculumGapOut(BaseModel):
    """The department's view: the catalog against the postings, not one student."""
    career: str | None = Field(description="The career asked for; null for every career")
    posting_count: int = Field(description="Job postings behind this view")
    min_demand: float = Field(description=(
        "Share of a career's postings a skill needs to count as demanded: the same "
        "threshold a student's gap uses"))
    demanded: int = Field(description="Skills the postings in scope ask for")
    taught: int = Field(description="Of those, the ones at least one course teaches")
    coverage: float = Field(description=(
        "taught / demanded. Each skill counts once, however many postings name it"))
    coverage_percent: int
    uncovered: list[CurriculumSkill] = Field(
        description="Demanded skills no course teaches, most in demand first")
    not_asked: list[TaughtSkill] = Field(
        description="Skills the catalog teaches that no posting in scope names, in "
                    "taxonomy order")
    below_threshold: list[BelowThresholdSkill] = Field(
        description="Skills some posting in scope names, but too few to reach min_demand "
                    "in any career of it, most named first. Counted in neither list "
                    "above, and listed so that the threshold hides nothing")
    per_career: list[CareerCoverageOut] = Field(
        description="Every career's coverage, whatever the scope")
    sample_note: str = Field(description="How few postings these gaps rest on")
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
