#!/bin/sh

echo "Running docker compose up for docker-compose.full.yml"
echo
echo "To interact with individual containers use:"
echo
echo "The api container:"
echo "docker compose -f docker-compose.full.yml exec doubtfire-api /bin/bash"
echo
echo "The web container"
echo "docker compose -f docker-compose.full.yml exec doubtfire-web /bin/bash"
echo

docker compose -f docker-compose.full.yml up --build


