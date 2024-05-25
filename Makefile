NAME			= Inception
USER			= ekaik-ne

WP_NAME			= wordpress
MDB_NAME		= mariadb

LIST_VOLUMES	= $(shell docker volume ls -q)
HOME_PATH		= $(shell echo $$HOME/.docker)
SYSTEM_USER		= $(shell echo $$USER)

all: setup up

up:
	sudo docker compose --file ./srcs/docker-compose.yml --project-name=$(NAME) up --build

down:
	sudo docker-compose --file=./srcs/docker-compose.yml --project-name=$(NAME) down

setup: system folders
	sudo grep -q $(USER) /etc/hosts || sudo sed -i "3i127.0.0.1\t$(USER).42.fr" /etc/hosts

system: install upgrade

install: 
	sudo apt update -y && sudo apt upgrade -y
	@if [ $$? -eq 0 ]; then \
		sudo apt install -y docker.io docker-compose; \
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
	mkdir -p ${HOME_PATH}/cli-plugins
	curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ${HOME_PATH}/cli-plugins/docker-compose
	chmod +x ${HOME_PATH}/cli-plugins/docker-compose
	sudo mkdir -p /usr/local/lib/docker/cli-plugins
	sudo mv /home/${SYSTEM_USER}/.docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose

folders:
	sudo mkdir -p $(HOME_PATH)/data/$(MDB_NAME)
	sudo mkdir -p $(HOME_PATH)/data/$(WP_NAME)

clean:
	docker volume rm $(LIST_VOLUMES)
	sudo rm -rf $(HOME_PATH)

fclean: down clean
	docker system prune -all --force --volumes

re: fclean all

.PHONY: all up down setup system install upgrade fclean clean re
