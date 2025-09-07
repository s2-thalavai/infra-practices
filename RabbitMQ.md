### RabbitMQ Setup

Use Docker image:

    docker run -d --hostname rabbit --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:management

Access via:

    Windows: localhost:15672

WSL: Use host IP from ip route

the default username and password for the RabbitMQ Management UI (on port 15672) are:

    Username: guest
    
    Password: guest


<img width="1918" height="967" alt="image" src="https://github.com/user-attachments/assets/e74f51ae-52dd-4d27-b894-39b46ab11e2e" />


However, there's a catch: 🔒 The guest user is only allowed to connect from localhost. 
If you're accessing RabbitMQ from a browser outside the container (e.g., from Windows or WSL), authentication will fail.

### Set Custom Credentials
To allow remote access, define your own user with environment variables:

    docker run -d --hostname rabbit --name rabbitmq \
      -p 5672:5672 -p 15672:15672 \
      -e RABBITMQ_DEFAULT_USER=admin \
      -e RABBITMQ_DEFAULT_PASS=admin \
      rabbitmq:management
      
Then log in at http://localhost:15672 using:

    Username: admin
    
    Password: admin

<img width="892" height="542" alt="image" src="https://github.com/user-attachments/assets/96aeeb7c-1bca-45c5-88f7-94de999238bb" />

<img width="1918" height="401" alt="image" src="https://github.com/user-attachments/assets/b8aebf2f-9c49-4d02-88c7-ab0406c98d46" />

<img width="1918" height="1016" alt="image" src="https://github.com/user-attachments/assets/42819bda-7900-4fc6-89b6-5df7897a1f6b" />

