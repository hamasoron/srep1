# プロジェクトディレクトリ構造

```
.
├── app/
│   ├── front-nginx/
│   │   ├── default.conf
│   │   ├── Dockerfile
│   │   ├── style.css
│   │   ├── script.js
│   │   └── index.html
│   ├── api-python/
│   │   ├── requirements.txt
│   │   ├── app.py
│   │   └── Dockerfile
│   └── db-init/
│       ├── init.sql
│       └── Dockerfile
├── .git/
├── .github/
│   └── workflows/
│       ├── front-nginx.yml
│       ├── api-python.yml
│       └── db-init.yml
├── terraform/
│   ├── modules/
│   │   ├── ecs/
│   │   ├── ecr/
│   │   ├── alb/
│   │   ├── rds/
│   │   ├── vpc/
│   │   ├── sg/
│   │   └── iamrole/
│   ├── environments/
│   │   ├── dev/
│   │   ├── stg/
│   │   └── prod/
│   └── README.md
├── README.md
├── directory.md
├── srep1-prod-api-python-taskdef.json
├── srep1-prod-db-init-taskdef.json
├── srep1-prod-front-nginx-taskdef.json
├── .gitignore
└── .gitattributes
``` 