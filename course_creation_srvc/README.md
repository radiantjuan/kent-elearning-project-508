# Kent E-Learning Platform: Course Creation Service
By: Radiant C. Juan - K230925


## Docker repository
There are 2 ways to run this app in docker engine

### Pre-requisite
1. create a network first:
```
docker network create laravel-network
```

2. install bitnami/mariadb
```
docker run -d --name mariadb \
  --env ALLOW_EMPTY_PASSWORD=yes \
  --env MARIADB_USER=bn_myapp \
  --env MARIADB_DATABASE=bitnami_myapp \
  --network laravel-network \
  --volume mariadb_data:/bitnami/mariadb \
  bitnami/mariadb:latest
```


### 1. Pull docker image and directly run it by using this 

Pull docker image
```
docker pull radiantcjuan/k230925_kent_elearning_course_creation_service
```

run the image:
```
docker run -p 80:80 --name kent-elearning-course-service --network=laravel-network --rm radiantcjuan/k230925_kent_elearning_course_creation_service
```

### 2. Build the image locally and docker

build the image using `Dockerfile` on the root directory
```
docker image build --tag <anytag you want> .
```

run the image you build
```
docker run -p 80:80 --name kent-elearning-course-service --network=laravel-network --rm radiantcjuan/k230925_kent_elearning_course_creation_service
```

### 3. Migrate the database
once running go to the container terminal
```
docker exec -it kent-elearning-course-service bash
```

then migrate the database

```
php artisan migrate --seed
```
