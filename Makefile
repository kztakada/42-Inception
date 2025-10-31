D_COMPOSE_FILE = ./srcs/docker-compose.yml
D_COMPOSE_CMD = docker compose -f $(D_COMPOSE_FILE)
MAKE_CREDENTIALS = ./srcs/requirements/tools/make_credentials.sh
ENV_FILE = ./srcs/.env
INCEPTION_ENV = $(HOME)/Inception/.env

all: build

build: $(ENV_FILE)
	mkdir -p $(HOME)/data/DB $(HOME)/data/WordPress
	chmod +x $(MAKE_CREDENTIALS) && $(MAKE_CREDENTIALS)
	$(D_COMPOSE_CMD) up --build -d

kill:
	$(D_COMPOSE_CMD) kill

stop:
	$(D_COMPOSE_CMD) stop

start:
	$(D_COMPOSE_CMD) start

down:
	$(D_COMPOSE_CMD) down

clean:
	$(D_COMPOSE_CMD) down -v --rmi all --remove-orphans

fclean: clean
	sudo rm -rf $(HOME)/data/
	docker image prune -a -f

sys_clean:
	docker system prune -a --volumes -f

re: fclean build

$(ENV_FILE):
	@echo "📝 .env file not found. Attempting to copy from template..."
	@if [ -f $(INCEPTION_ENV) ]; then \
		cp $(INCEPTION_ENV) $(ENV_FILE); \
	else \
		echo "❌ Error: Template file $(INCEPTION_ENV) not found!"; \
		echo "💡 Please create $(ENV_FILE) manually or provide $(INCEPTION_ENV)"; \
		exit 1; \
	fi

.PHONY: all build kill stop down clean fclean re sys_clean