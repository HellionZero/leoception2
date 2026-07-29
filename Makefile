COMPOSE = cd srcs && docker compose 

up:
	${COMPOSE} up -d

down:
	${COMPOSE} down

build:
	${COMPOSE} build

fclean:
	${COMPOSE} down --rmi all --volumes --remove-orphans

status:
	${COMPOSE} ps

logs:
	${COMPOSE} logs

config:
	${COMPOSE} config

.PHONY:
	up down build fclean status logs config
