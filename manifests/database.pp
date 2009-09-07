define mysql::database($name, $ensure) {

    case $ensure {
        present: {
            exec { "Mysql: create $name db":
                    command => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"CREATE DATABASE $name\";",
                    unless => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"SHOW DATABASES;\" | grep '$name'",
                    require => Class['mysql']
            }
        }
        absent: {
            exec { "Mysql: drop $name db":
                    command => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"DROP DATABASE $name\";",
                    onlyif => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"SHOW DATABASES;\" | grep '$name'",
                    require => Class['mysql']
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for mysql::database"
        }
    }
}

# define mysql::user($password) {
#   exec { "Mysql: create $name user":
#                   command = "/usr/bin/echo 'CREATE USER \'${name}\'@\'localhost\' IDENTIFIED BY \'${password}\'; 
#                   GRANT ALL PRIVILEGES ON *.* TO \'monty\'@\'localhost\' WITH GRANT OPTION;"}
#                   onlyif => 
# }