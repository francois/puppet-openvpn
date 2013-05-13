#!/bin/bash

EASY_RSA_PATH="/usr/share/doc/openvpn/examples/easy-rsa/2.0"
CLIENT_MODULE="../../openvpn_client"
SERVER_KEYS_PATH="../configs/net/keys"

if [[ ! -d "./easy-rsa" ]]; then
	if [[ ! -d "${EASY_RSA_PATH}" ]]; then
		echo "Cannot find a copy of easy-rsa, please install openvpn first."

		exit 1;
	else
		read -p  "OpenVPN easy-rsa detected, you you want to copy it manually? [y/N] " -n 1 -r REPLY
		echo;

		if [[ $REPLY =~ ^[Yy]$ ]]; then
			mkdir "$(pwd)/easy-rsa"
			cp -R "${EASY_RSA_PATH}"/* "./easy-rsa/"
		else
			echo "Failed, exiting..."
			exit 1;
		fi
	fi
fi

cd "./easy-rsa"

read -p  "Do you want to edit the certificate variables (or run interactively)? [y/N] " -n 1 -r REPLY
echo;

if [[ $REPLY =~ ^[Yy]$ ]]; then
	if [[ -z "${EDITOR}" ]]; then
		EDITOR="vi"
	fi

	${EDITOR} "./vars"

	RETURN="$?"

	BATCH_MODE=""
else
	RETURN="0"

	BATCH_MODE="--batch"
fi

if [[ "${RETURN}" -gt 0 ]]; then
	echo "Exiting..."
	exit 1;
else
	. ./vars

	./clean-all --batch 2>&1 /dev/null >> /dev/null

	./build-ca ${BATCH_MODE}

	if [[ "$?" -gt 0 ]]; then
		echo "Failed building CA, exiting..."
		exit 1;
	fi

	./build-key-server ${BATCH_MODE} server

	if [[ "$?" -gt 0 ]]; then
		echo "Failed server certificates, exiting..."
		exit 1;
	fi

	./build-dh ${BATCH_MODE}

	if [[ "$?" -gt 0 ]]; then
		echo "Failed diffie hillman key, exiting..."
		exit 1;
	fi

	export KEY_CN="${KEY_CN}-client"
	export KEY_NAME="${KEY_NAME}-client"
	
	./build-key ${BATCH_MODE} clients
	
	if [[ "$?" -gt 0 ]]; then
		echo "Failed client certificates, exiting..."
		exit 1;
	fi

	echo;
	echo "Installing server certificates..."

	mkdir -p "${SERVER_KEYS_PATH}"
	cp -a ./keys/ca.crt	"${SERVER_KEYS_PATH}/"
	cp -a ./keys/dh1024.pem	"${SERVER_KEYS_PATH}/"
	cp -a ./keys/server.crt	"${SERVER_KEYS_PATH}/"
	cp -a ./keys/server.key	"${SERVER_KEYS_PATH}/"

	echo;
	read -p  "Do you want to copy the clients certificate to the openvpn client puppet module? [y/N] " -n 1 -r REPLY
	echo;
	
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		echo "Copying client certificates to puppet client module..."

		if [[ ! -d "../${CLIENT_MODULE}" ]]; then
			echo "Failed, cannot find openvpn-client puppet module, exiting..."
			echo "Remember to copy ca.crt, clients.crt, and clients.key files to the openvpn client puppet module."

			exit 1;
		else
			mkdir -p "../${CLIENT_MODULE}/files/configs/net/keys/"

			cp -a ./keys/ca.crt "../${CLIENT_MODULE}/files/configs/net/keys/"
			cp -a ./keys/clients.key "../${CLIENT_MODULE}/files/configs/net/keys/"
			cp -a ./keys/clients.crt "../${CLIENT_MODULE}/files/configs/net/keys/"
		fi
	else
		echo "Remember to copy ca.crt, clients.crt, and clients.key files to the openvpn client puppet module."
	fi

	echo;
	echo "Done..."
	exit 0;
fi
