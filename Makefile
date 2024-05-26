$(shell touch srcs/.env)

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

RED				= \033[0;31m
GREEN			= \033[0;32m
YELLOW			= \033[0;33m
RESET			= \033[0m

all: setup up

up:
	@if docker compose ls | grep -qi "^$(NAME)\s*running"; then \
		echo "${YELLOW}-----Docker project '$(NAME)' is already running-----${RESET}"; \
	else \
		echo "${YELLOW}-----Starting Docker project '$(NAME)'-----${RESET}"; \
		sudo docker compose --verbose --file ./srcs/docker-compose.yml --project-name=$(NAME) up --build -d; \
		echo "${GREEN}-----Docker project '$(NAME)' has been started successfully-----${RESET}"; \
	fi

down:
	@if docker compose ls | grep -qi "^$(NAME)"; then \
		echo "${YELLOW}-----Stopping Docker project '$(NAME)'-----${RESET}"; \
		sudo docker compose --file=./srcs/docker-compose.yml --project-name=$(NAME) down; \
		echo "${GREEN}-----Docker project '$(NAME)' has been stopped successfully-----${RESET}"; \
	else \
		echo "${YELLOW}-----Docker project '$(NAME)' is not active at the moment-----${RESET}"; \
	fi

setup: system env folders 
	sudo grep -q $(USER) /etc/hosts || sudo sed -i "3i127.0.0.1\t$(USER).42.fr" /etc/hosts

system: install upgrade

install:
	@echo "${YELLOW}-----Updating System----${RESET}"
	sudo apt update -y && sudo apt upgrade -y
	@if [ $$? -eq 0 ]; then \
		echo "${GREEN}-----System updated-----${RESET}"; \
		if ! command -v docker &> /dev/null; then \
			echo "${YELLOW}-----Checking Docker.io-----${RESET}"; \
			if apt-cache show docker.io | grep -q "Depends: containerd"; then \
				echo "${YELLOW}-----Installing Docker.io-----${RESET}"; \
				sudo apt install -y docker.io; \
				if [ $$? -eq 0 ]; then \
					echo "${GREEN}-----Docker.io installed-----${RESET}"; \
				else \
					echo "${RED}-----Docker.io installation failed-----${RESET}"; \
					exit 1; \
				fi; \
			else \
				echo "${YELLOW}-----Docker.io not supported, installing Docker-----${RESET}"; \
				sudo apt install -y docker; \
				if [ $$? -eq 0 ]; then \
					echo "${GREEN}-----Docker installed-----${RESET}"; \
				else \
					echo "${RED}-----Docker installation failed-----${RESET}"; \
					exit 1; \
				fi; \
			fi; \
		else \
			echo "${YELLOW}-----Docker is already installed-----${RESET}"; \
		fi; \
		if ! command -v docker-compose &> /dev/null; then \
			echo "${YELLOW}-----Installing Docker Compose-----${RESET}"; \
			sudo apt install -y docker-compose; \
			if [ $$? -eq 0 ]; then \
				echo "${GREEN}-----Docker Compose installed-----${RESET}"; \
			else \
				echo "${RED}-----Docker Compose installation failed-----${RESET}"; \
				exit 1; \
			fi; \
		else \
			echo "${YELLOW}-----Docker Compose is already installed-----${RESET}"; \
		fi; \
		echo "${GREEN}-----System installed successfully-----${RESET}"; \
	else \
		echo "${RED}-----System update failed-----${RESET}"; \
	fi

upgrade:
	@if command -v docker compose &> /dev/null && docker compose version | grep -q "2.2.3"; then \
		echo "${GREEN}-----Docker Compose is already updated to V2.2.3-----${RESET}"; \
	else \
		echo "${YELLOW}-----Updating Docker Compose to V2.2.3-----${RESET}"; \
		if ! command -v curl &> /dev/null; then \
			echo "${YELLOW}-----Installing curl-----${RESET}"; \
			sudo apt -y install curl; \
		fi; \
		mkdir -p ${HOME_PATH}/.docker/cli-plugins; \
		curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ${HOME_PATH}/.docker/cli-plugins/docker-compose; \
		chmod +x ${HOME_PATH}/.docker/cli-plugins/docker-compose; \
		sudo mkdir -p /usr/local/lib/docker/cli-plugins; \
		sudo mv ${HOME_PATH}/.docker/cli-plugins/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose; \
		echo "${GREEN}-----Docker Compose updated to V2.2.3-----${RESET}"; \
	fi


folders:
	@if [ -d "/home/$(USER)/data/$(MDB_NAME)" ]; then \
		echo "${GREEN}-----Data folder $(MDB_NAME) already exists. No action needed.-----${RESET}"; \
	else \
		echo "${YELLOW}-----Creating data folder $(MDB_NAME)-----${RESET}"; \
		sudo mkdir -p /home/$(USER)/data/$(MDB_NAME); \
		echo "${GREEN}-----Data folder $(MDB_NAME) created successfully-----${RESET}"; \
	fi
	@if [ -d "/home/$(USER)/data/$(WP_NAME)" ]; then \
		echo "${GREEN}-----Data folder $(WP_NAME) already exists. No action needed.-----${RESET}"; \
	else \
		echo "${YELLOW}-----Creating data folder $(WP_NAME)-----${RESET}"; \
		sudo mkdir -p /home/$(USER)/data/$(WP_NAME); \
		echo "${GREEN}-----Data folder $(WP_NAME) created successfully-----${RESET}"; \
	fi

env:
	@if [ -f "./srcs/.env" ] && [ "$$(cat ./srcs/.env)" = "MDB_DATABASE=db_inception \nMDB_USER=user_db\nMDB_PASS=pass_db\n\nURL=ekaik-ne.42.fr\n\nPATH_VOLUME=/home/$(USER)/data\n\nADM_USER=Norminette \nADM_PASS=N0rm1n3tt3L0v3M4rv1n\nADM_MAIL=norminette@admin.42sp.org.br\n\nUSER_NAME=ekaik-ne\nUSER_PASS=CutiaCururu\nUSER_MAIL=ekaik-ne@student.42sp.org.br" ]; then \
		echo "${GREEN}-----The .env file content is already up to date. No action needed.-----${RESET}"; \
	else \
		echo "${YELLOW}-----Updating .env file-----${RESET}"; \
		echo "MDB_DATABASE=db_inception \n\
MDB_USER=user_db\n\
MDB_PASS=pass_db\n\
\n\
URL=ekaik-ne.42.fr\n\
\n\
PATH_VOLUME=/home/$(USER)/data\n\
\n\
ADM_USER=Norminette \n\
ADM_PASS=N0rm1n3tt3L0v3M4rv1n\n\
ADM_MAIL=norminette@admin.42sp.org.br\n\
\n\
USER_NAME=ekaik-ne\n\
USER_PASS=CutiaCururu\n\
USER_MAIL=ekaik-ne@student.42sp.org.br" > ./srcs/.env; \
		echo "${GREEN}-----The .env file has been updated successfully.-----${RESET}"; \
	fi


database:
	@if ! docker ps --filter "name=$(MDB_NAME)" --format '{{.Names}}' | grep -q $(MDB_NAME); then \
		echo "${YELLOW}-----The container $(MDB_NAME) is not running. Please start the Docker project to access the database.-----${RESET}"; \
	else \
		echo "${YELLOW}-----Connecting to Database:-----${RESET}"; \
		docker exec -it $(MDB_NAME) mysql -u $(MDB_USER) --password=$(MDB_PASS) --database=$(MDB_DATABASE); \
	fi	

clean:
	@if docker volume ls -q | grep -q .; then \
		echo "${YELLOW}-----Stopping Docker project '$(NAME)' and removing volumes-----${RESET}"; \
		$(MAKE) down; \
		docker volume rm $(LIST_VOLUMES); \
		echo "${YELLOW}-----Removing local data and .env file-----${RESET}"; \
		sudo rm -rf /home/$(USER)/data; \
		sudo rm ./srcs/.env; \
		echo "${GREEN}-----Cleanup completed successfully-----${RESET}"; \
	else \
		echo "${YELLOW}-----No Docker volumes found. Nothing to clean.-----${RESET}"; \
	fi

fclean: clean
	@echo "${YELLOW}-----Performing full Docker system prune-----${RESET}"
	docker system prune --all --force --volumes
	@echo "${GREEN}-----Full cleanup completed successfully-----${RESET}"

re: fclean all

.PHONY: all up down setup system install upgrade fclean clean re
