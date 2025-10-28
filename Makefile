D_COMPOSE_FILE = ./srcs/docker-compose.yml
D_COMPOSE_CMD = docker compose -f $(D_COMPOSE_FILE)
CREDENTIALS_SH = ./secrets/make_ssl_credentials.sh

all: build

build:
	mkdir -p $(HOME)/data/DB $(HOME)/data/WordPress
	chmod +x $(CREDENTIALS_SH) && $(CREDENTIALS_SH)
	$(D_COMPOSE_CMD) up --build -d

kill:
	$(D_COMPOSE_CMD) kill

stop:
	$(D_COMPOSE_CMD) stop

down:
	$(D_COMPOSE_CMD) down

clean:
	$(D_COMPOSE_CMD) down -v --rmi all --remove-orphans

fclean: clean
	sudo rm -rf $(HOME)/data/

sys_clean:
	docker system prune -a --volumes -f

sys_fclean: sys_clean
	docker images prune -a -f

re: fclean build

.PHONY: all build kill stop down clean fclean re sys_clean sys_fclean