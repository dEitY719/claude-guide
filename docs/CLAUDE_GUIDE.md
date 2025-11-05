# 🚀 CLAUDE Code 사용 가이드 — “짧은 문서, 단순한 명령”

> **목적:**  
> CLAUDE Code를 처음 사용하는 동료들이 “효율적인 도구 사용법”과 “짧고 명확한 문서 작성 방식”을 이해하고  
> 실무 프로젝트에 바로 적용할 수 있도록 돕기 위한 가이드입니다.

---

## 🧩 1. 최초 질문

> **Q:**  
> “Claude Code 툴 관련 가이드 문서를 읽고 있습니다.  
> 아래 내용이 이해가 안 돼요. 쉽게 예를 들어 설명해주세요.  
> 어떻게 활용하는 것이 효과적인 사용법인지, 구체적인 예시를 들어 설명하면  
> Claude Code 처음 사용하는 동료들의 툴 사용 효율이 증가할 거예요.”

> **참고한 원문:**  
> ```
> Use CLAUDE.md as a Forcing Function.
> If your CLI commands are complex and verbose, don’t write paragraphs of documentation to explain them.
> That’s patching a human problem.
> Instead, write a simple bash wrapper with a clear, intuitive API and document that.
> Keeping your CLAUDE.md as short as possible is a fantastic forcing function for simplifying your codebase and internal tooling.
> ```

---

## 💡 2. 핵심 메시지:  
### “문서를 길게 쓰지 말고, 사람이 쓰기 쉽게 **명령어 자체를 단순하게 만들어라**”

### 이유 🔍
- **긴 문서 = 복잡한 사용성의 신호**  
  → CLI(명령어)가 어렵기 때문에 설명이 길어지는 것.  
  → 결국 *사람이 아니라 명령이 문제*.

- **문서를 짧게 유지하려면?**  
  → 명령어가 스스로 설명이 되어야 함.  
  → 즉, 사용법을 “문서로 설명하는” 대신 “명령이 직관적으로 느껴지게” 만들어야 함.

- **CLAUDE.md를 짧게 쓰는 것이 바로 강제 장치(Forcing Function)**  
  → “이걸 짧게 쓰려면, 명령 자체를 단순하게 바꿔야겠다”는 식으로  
     자연스럽게 팀의 CLI/API가 개선된다.

---

## ⚙️ 3. 해결 방법:  
### 명령어를 단순화하는 **Bash Wrapper** 패턴

문서를 줄이는 핵심은 **복잡한 CLI를 래퍼로 감싸는 것**이에요.

---

### ❌ 나쁜 예시 — 문서로만 설명하는 방식

```bash
# 개발 서버 띄우려면 아래 6단계 실행
poetry install
poetry run alembic upgrade head
export APP_ENV=dev
export DATASET=s3://bucket/proj/v2
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
python scripts/warm_cache.py --source s3://...
````

CLAUDE.md에는 이런 긴 설명이 들어갑니다:

```
1. 환경설정
2. 마이그레이션 실행
3. 데이터셋 경로 설정
4. 서버 실행
5. 캐시 예열...
```

→ 문서는 길어지고, 초심자는 그대로 복붙하다가 에러를 내기 쉽습니다.

---

### ✅ 좋은 예시 — 명령 자체를 단순화

모든 절차를 **하나의 명령으로 감싼다:**

```bash
# tools/dev.sh
#!/usr/bin/env bash
set -euo pipefail

cmd="${1:-}"

case "$cmd" in
  up)
    echo "🔧 Setting up dev environment..."
    poetry install
    poetry run alembic upgrade head
    APP_ENV=dev DATASET=${DATASET:-"s3://bucket/proj/v2"} \
      uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
    ;;
  test)
    poetry run pytest -q
    ;;
  *)
    echo "Usage: ./tools/dev.sh {up|test}"
    ;;
esac
```

**CLAUDE.md에는 이렇게만 쓰면 충분합니다 👇**

```markdown
## Dev (80% use cases)
- 서버 시작: `./tools/dev.sh up`
- 테스트: `./tools/dev.sh test`
- 항상 `python 3.11`, `poetry` 사용
- 에러나 고급 설정은 `docs/dev_tool_docs.md` 참고
```

→ 누구나 3줄만 읽어도 바로 개발 서버를 띄울 수 있음.
→ 긴 절차를 문서가 아닌 코드가 대신함.

---

### 💡 “Forcing Function” 효과

CLAUDE.md를 “짧게 유지하겠다”는 규칙 하나만 지켜도,
자연스럽게 다음이 따라옵니다:

* 복잡한 절차가 점점 하나의 명령으로 묶임
* 온보딩 문서가 짧고 깔끔해짐
* 초보자 실수가 줄고, 팀 내 환경이 표준화됨

---

## 🧠 4. 적용 예시

| 기능       | 복잡한 원래 명령                      | 단순화된 명령                    |
| -------- | ------------------------------ | -------------------------- |
| 개발 서버 실행 | 여러 줄 환경설정+uvicorn 실행           | `./tools/dev.sh up`        |
| 테스트 실행   | `pytest -q --disable-warnings` | `./tools/dev.sh test`      |
| 데이터 동기화  | `aws s3 sync ...` + 후처리        | `./tools/data.sh pull`     |
| 패키지 릴리스  | 여러 단계의 git tag/publish         | `./tools/release.sh patch` |

---

## 🛠️ 5. 실무 적용 절차 (요약)

1. **레포 루트에 `tools/` 폴더 추가**
2. 복잡한 CLI를 `tools/<name>.sh`로 감싸기
3. 각 래퍼는 Help/Usage 내장 (사람이 읽기 쉬운 메시지)
4. `CLAUDE.md`는 5~10개의 핵심 불릿만 유지
5. 나머지 세부 옵션/에러케이스는 `docs/<tool>_docs.md`로 분리

---

## 🧩 6. 기본 구조 예시

```
repo/
├─ CLAUDE.md
├─ tools/
│  ├─ dev.sh
│  ├─ data.sh
│  └─ release.sh
├─ docs/
│  ├─ dev_tool_docs.md
│  ├─ data_tool_docs.md
│  └─ release_tool_docs.md
└─ app/, scripts/, tests/ ...
```

---

## ⚡ 7. WSL + VSCode 개발자를 위한 자동 생성 스크립트

아래 스크립트(`scripts/generate_tools.sh`)를 실행하면
현재 프로젝트를 자동 스캔하고 `tools/*.sh` 템플릿을 만들어줍니다.

```bash
mkdir -p scripts
curl -o scripts/generate_tools.sh https://your-internal-link/tools-generator.sh
chmod +x scripts/generate_tools.sh
./scripts/generate_tools.sh
```

이후:

```bash
./tools/dev.sh help
./tools/data.sh help
./tools/release.sh

$ tree ./tools
./tools
├── commit.sh
├── data.sh
├── dev.sh
└── release.sh
```

---

## 🎯 8. 핵심 요약

| 원칙                      | 설명                                                       |
| ----------------------- | -------------------------------------------------------- |
| **문서는 최소화**             | CLAUDE.md는 “핵심 불릿”만. 10줄 이내면 이상적.                        |
| **명령어는 단순화**            | 복잡한 로직은 bash wrapper로 감싸기.                               |
| **표준화된 툴링**             | `tools/dev.sh`, `tools/data.sh`, `tools/release.sh` 관례화. |
| **고급 내용 분리**            | 예외 케이스는 별도 `docs/` 파일로.                                  |
| **Forcing Function 효과** | 짧은 문서를 강제하면, 도구가 스스로 단순해진다.                              |

---

> ✨ **한 줄 정리**
>
> “좋은 CLAUDE.md란,
> 긴 설명 없이도 `./tools/dev.sh up` 한 줄로 팀원이 바로 프로젝트를 띄울 수 있는 문서다.”
