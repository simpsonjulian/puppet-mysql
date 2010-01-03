define mysql::database($dbname, $ensure) {

    case $ensure {
        present: {
            exec { "Mysql: create $dbname db":
                    command => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"CREATE DATABASE $dbname\";",
                    unless => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"SHOW DATABASES;\" | grep '$dbname'",
                    require => Class['mysql']
            }
        }
        absent: {
            exec { "Mysql: drop $dbname db":
                    command => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"DROP DATABASE $dbname\";",
                    onlyif => "/usr/bin/mysql -u root -p${mysql_root_password} --execute=\"SHOW DATABASES;\" | grep '$dbname'",
                    require => Class['mysql']
            }
        }
        default: {
            fail "Invalid 'ensure' value '$ensure' for mysql::database"
        }
    }
}

define mysql::user($password) {
  file { 
    "script file":
      path => "/var/tmp/user.sql",
      content => template("mysql/user.sql.erb"),
      ensure => file;
  }

  exec { 
    "Mysql: create $name user":
     command => "/usr/bin/mysql -uroot -p${mysql_root_password} < /var/tmp/user.sql",
     require => File["script file"];
    "delete script file":
     command => "/usr/bin/rm /var/tmp/user.sql",
     require => Exec["create ${name} user"];
  }
    
}

class mysql {

  package{ [mysql-client, mysql-server, libmysqlclient15-dev]: ensure => installed }
  
  if $mysql_root_password { 
        
        exec { "Set MySQL server root password":
          unless => "mysqladmin -uroot -p$mysql_root_password status",
          path => "/bin:/usr/bin",
          command => "mysqladmin -uroot password $mysql_root_password",
          require => [ Package["mysql-server"], Package["mysql-client"] ]
        }
    }
    else {
        warning("no mysql root password given - sorry")
    }
  }

