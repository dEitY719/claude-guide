# Claude CLI guide

- cladue를 사용하다 보면, weekly limit에 걸림
- 원인은 claude를 제대로 사용 못해서 ㅠ
- 잘 사용하려면 claude 공식 문서를 참고해서 공부해야함.


---


- 일단, "shoot and fogot" 전략을 알게되었고, claude.md 파일을 효율적으로 최적화해야함.
- 핵심은 “문서를 길게 쓰지 말고, 사람이 쓰기 쉽게 **명령어 자체를 단순하게 만들어라**”


[Claude Guide 문서에 배경에 대한 자세한 내용이 있음](./docs/CLAUDE_GUIDE.md)


## 사용 방법


1. claude cli 실행
2. `/init` 수행하면 CLAUDE.md 파일 만듬
3. claude에게 ./docs/PROJECT_SETUP_PROMPT.md 파일 참고해서 CLAUDE.md 파일을 최적화하라고 요청


---


## TL;DR


-(anyway) 기존 800줄 이상의 무거웠던 나의 CLAUDE.md 파일이 190줄로 작아지고, 대신 tools 디렉토리 밑에 claude를 위한 명확한 스크립트 들이 추가됨.
