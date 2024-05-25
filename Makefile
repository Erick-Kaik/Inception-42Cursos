include srcs/.env

export MDB_DATABASE
export MDB_USER
export MDB_PASS

NAME			= Inception
USER			= ekaik-ne

WP_NAME			= wordpress
MDB_NAME		= mariadb

LIST_VOLUMES	= $(shell docker volume ls -q)
HOME_PATH		= $(shell echo $$HOME)
SYSTEM_USER		= $(shell echo $$USER)

all: setup up

up:
	sudo docker compose --verbose --file ./srcs/docker-compose.yml --project-name=$(NAME) up --build -d

down:
	sudo docker compose --file=./srcs/docker-compose.yml --project-name=$(NAME) down

setup: system env folders 
	sudo grep -q $(USER) /etc/hosts || sudo sed -i "3i127.0.0.1\t$(USER).42.fr" /etc/hosts

system: install upgrade

install: 
	sudo apt update -y && sudo apt upgrade -y
	@if [ $$? -eq 0 ]; then \
		sudo apt install -y docker.io && sudo apt install -y docker-compose; \
		if [ $$? -eq 0 ]; then \
			echo "Docker e Docker Compose instalados!!!"; \
		else \
			echo "Erro na instalação do Docker e Docker Compose!!!"; \
		fi \
	else \
		echo "Atualização do sistema falhou!!!"; \
	fi 

upgrade: 
	sudo apt -y install curl
	mkdir -p ${HOME_PATH}/.docker/cli-plugins
	curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ${HOME_PATH}/.docker/cli-plugins/docker-compose
	chmod +x ${HOME_PATH}/.docker/cli-plugins/docker-compose
	sudo mkdir -p /usr/local/lib/docker/cli-plugins
	sudo mv /home/${SYSTEM_USER}/.docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose


folders:
	sudo mkdir -p $(HOME_PATH)/data/$(MDB_NAME)
	sudo mkdir -p $(HOME_PATH)/data/$(WP_NAME)

env:
	echo "MDB_DATABASE=db_inception \n\
MDB_USER=user_db \n\
MDB_PASS=pass_db \n\
\n\
URL=ekaik-ne.42.fr \n\
\n\
PATH_VOLUME=$(HOME_PATH)/data \n\
\n\
ADM_USER=Norminette \n\
ADM_PASS=N0rm1n3tt3L0v3M4rv1n \n\
ADM_MAIL=norminette@admin.42sp.org.br \n\
\n\
USER_NAME=ekaik-ne \n\
USER_PASS=CutiaCururu \n\
USER_MAIL=ekaik-ne@student.42sp.org.br \ " > ./srcs/.env

database:
	@if ! docker ps --filter "name=$(MDB_NAME)" --format '{{.Names}}' | grep -q $(MDB_NAME); then \
		echo "O contêiner $(MDB_NAME) não está em execução. Por favor, inicie o projeto Docker para acessar o banco de dados."; \
		exit 1; \
	fi
	@echo "Conectando ao Banco: "
	docker exec -it mariadb mysql -u $(MDB_USER) --password=$(MDB_PASS) -e "USE $(MDB_DATABASE);"

clean:
	docker volume rm $(LIST_VOLUMES)
	sudo rm -rf $(HOME_PATH)/data
	sudo rm ./srcs/.env

fclean: down clean
	docker system prune -all --force --volumes

re: fclean all

.PHONY: all up down setup system install upgrade fclean clean re
