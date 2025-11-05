# 새 프로젝트 초기 셋업 프롬프트

새 프로젝트를 시작할 때 Claude Code에 제출할 프롬프트입니다.
아래 템플릿을 복사하여 프로젝트 정보를 입력한 후 Claude에게 요청하세요.

---

## 📋 템플릿 (복사해서 사용)

```
새 프로젝트의 Developer Experience를 최적화하고 싶습니다.
다음과 같은 구조를 자동으로 생성해 주세요:

## 프로젝트 정보
- **프로젝트명**: [프로젝트명 입력]
- **설명**: [간단한 설명]
- **패키지 관리자**: [poetry | uv | pip]
- **프레임워크**: [FastAPI | Django | Flask | 없음]
- **앱 엔트리**: [예: src.backend.main:app 또는 manage.py]
- **데이터베이스**: [SQLite | PostgreSQL | MySQL | 없음]
- **테스트 도구**: [pytest | unittest | 없음]
- **마이그레이션**: [Alembic | Django migrations | 없음]
- **주요 데이터 소스**: [S3 | GCS | 로컬 경로 | API | 없음]

## 요청 사항

### 1. Tool Wrappers 생성
다음 3개의 bash 래퍼 스크립트를 생성해주세요 (tools/ 폴더):

**tools/dev.sh**
- `./tools/dev.sh up` — 개발 서버 시작 (자동으로 DB 초기화, 마이그레이션 등)
- `./tools/dev.sh test` — 테스트 실행
- `./tools/dev.sh format` — 코드 포매팅 + 린트 (한 줄로)
- `./tools/dev.sh shell` — 프로젝트 shell 진입

**tools/data.sh** (데이터 소스가 있는 경우)
- `./tools/data.sh pull-local [source] [dest]` — 데이터 다운로드
- `./tools/data.sh validate [path]` — 데이터 검증

**tools/release.sh**
- `./tools/release.sh patch|minor|major` — 자동 태깅 + 푸시

**tools/commit.sh**
- `./tools/commit.sh` — 대화형 커밋 (Conventional Commits 포맷)
  - 커밋 타입, scope, 설명 입력
  - 변경 사항 미리보기
  - 푸시 옵션

### 2. scripts/generate_tools.sh 생성
현재 프로젝트를 자동 감지하고 위 tools/*.sh를 생성하는 스크립트

### 3. CLAUDE.md 간소화
"Forcing Function" 원칙에 따라 짧고 실용적인 가이드:
- **Tech Stack**: 핵심만 (3-5줄)
- **Development (80% of work)**: Quick Start 3-4개 명령어 + Common Commands
- **Testing**: 기본 명령어만 (5줄)
- **Code Quality**: Before Commit 체크리스트
- **Architecture**: 핵심 특징 + Key Files
- **Git Workflow**: ./tools/commit.sh 사용법
- **Conventions**: 브랜치명, 커밋 메시지 규칙
- **Advanced/Troubleshooting**: docs/ 링크로 분리

### 4. Git Commit
모든 변경을 다음과 같이 커밋:

**Commit 1: Tool Wrappers & CLAUDE.md**
```
chore: Add tool wrappers and simplify CLAUDE.md (Forcing Function)

**Changes:**
- Create scripts/generate_tools.sh: Auto-generates tools/*.sh
- Add tools/dev.sh: Unified dev commands
- Add tools/data.sh: Data sync (if applicable)
- Add tools/release.sh: Semver release automation
- Add tools/commit.sh: Interactive commit wrapper
- Simplify CLAUDE.md: Forcing Function principle

**Benefits:**
- ↓ Learning curve: 3-4 intuitive commands
- ↓ Execution variance: 90%
- ↑ UX: Built-in help, error handling
```

**Commit 2: Git Workflow Guide**
```
docs: Add Git workflow and setup guides
```

## 추가 요청

### 선택사항
- [ ] GitHub Actions CI/CD 설정 (.github/workflows/)
- [ ] Pre-commit hooks 설정
- [ ] Docker 지원 (Dockerfile + docker-compose.yml)
- [ ] 개발자 온보딩 가이드 (docs/ONBOARDING.md)

---

## 주의사항

1. **tools/*.sh는 모두 실행 가능해야 함** (`chmod +x`)
2. **CLAUDE.md는 150-200줄 이내** (짧을수록 좋음)
3. **모든 명령어는 기본값 제공** (초보자도 쓸 수 있어야 함)
4. **Help 메시지 필수** (`./tools/dev.sh help` 등)
5. **LF 라인 엔딩** (WSL/Git 호환)

---

## 결과 확인

생성 후 다음을 실행하여 확인하세요:

\`\`\`bash
./tools/dev.sh help          # Help 메시지 표시
./tools/dev.sh format --help # Format 명령어 설명
cat CLAUDE.md | wc -l        # 라인 수 (150-200 범위인지 확인)
git log --oneline -3         # 최근 3개 커밋 확인
\`\`\`

---

## 예시: 실제 프롬프트

### Python + FastAPI + SQLModel + pytest 프로젝트
\`\`\`
새 프로젝트의 Developer Experience를 최적화하고 싶습니다.

## 프로젝트 정보
- **프로젝트명**: myproject
- **설명**: FastAPI 기반 REST API
- **패키지 관리자**: uv
- **프레임워크**: FastAPI
- **앱 엔트리**: src.main:app
- **데이터베이스**: PostgreSQL
- **테스트 도구**: pytest
- **마이그레이션**: Alembic
- **주요 데이터 소스**: S3 (parquet files)

[위의 요청 사항 1-4 복사]
\`\`\`

### Django + pytest 프로젝트
\`\`\`
새 프로젝트의 Developer Experience를 최적화하고 싶습니다.

## 프로젝트 정보
- **프로젝트명**: django_api
- **설명**: Django REST Framework API
- **패키지 관리자**: poetry
- **프레임워크**: Django
- **앱 엔트리**: manage.py runserver
- **데이터베이스**: PostgreSQL
- **테스트 도구**: pytest
- **마이그레이션**: Django migrations
- **주요 데이터 소스**: 없음

[위의 요청 사항 1-4 복사]
\`\`\`

---

## 참고: quantfolio 프로젝트 예시

이 프롬프트는 quantfolio 프로젝트에 적용된 다음 구조를 기반으로 합니다:

**파일 구조:**
```
project/
├── tools/
│   ├── dev.sh          # dev 명령어 통합
│   ├── data.sh         # 데이터 동기화
│   ├── release.sh      # 릴리스 자동화
│   └── commit.sh       # 대화형 커밋
├── scripts/
│   └── generate_tools.sh   # Tool 자동 생성
├── CLAUDE.md           # 간소화된 가이드 (188줄)
├── .github/workflows/  # CI/CD (선택)
└── docs/
    ├── setup/
    ├── database/
    └── troubleshooting/
```

**사용 예:**
```bash
./tools/dev.sh up       # 백엔드 시작
./tools/dev.sh test     # 테스트
./tools/dev.sh format   # 포매팅 (tox -e ruff)
./tools/commit.sh       # 커밋 (대화형)
```

---

## 다음 단계

1. 위 템플릿을 복사
2. 프로젝트 정보 입력
3. Claude Code에 제출
4. 생성된 파일 검토
5. 커밋 + 시작!

**팁**: 이 문서를 새 프로젝트의 `docs/PROJECT_SETUP_PROMPT.md`에 저장하면, 나중에 누군가 "이 구조를 다른 프로젝트에도 적용하고 싶어"라고 할 때 쉽게 찾을 수 있습니다.
