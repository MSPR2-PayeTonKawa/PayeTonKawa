#!/bin/bash

echo "🧬 Installing Xdebug for code coverage in all microservices..."

docker exec PTK-api-customers bash -c "
    apt-get update -qq && 
    apt-get install -y php-xdebug &&
    echo 'xdebug.mode=coverage' >> /etc/php/8.2/apache2/conf.d/20-xdebug.ini &&
    echo 'xdebug.mode=coverage' >> /etc/php/8.2/cli/conf.d/20-xdebug.ini &&
    service apache2 restart
"

docker exec PTK-api-products bash -c "
    apt-get update -qq && 
    apt-get install -y php-xdebug &&
    echo 'xdebug.mode=coverage' >> /etc/php/8.2/apache2/conf.d/20-xdebug.ini &&
    echo 'xdebug.mode=coverage' >> /etc/php/8.2/cli/conf.d/20-xdebug.ini &&
    service apache2 restart
"

docker exec PTK-api-orders bash -c "
    apt-get update -qq && 
    apt-get install -y php-xdebug &&
    echo 'xdebug.mode=coverage' >> /etc/php/8.2/apache2/conf.d/20-xdebug.ini &&
    echo 'xdebug.mode=coverage' >> /etc/php/8.2/cli/conf.d/20-xdebug.ini &&
    service apache2 restart
"

echo "✅ Xdebug installed successfully in all containers!"
echo "🧪 You can now run tests with coverage:"
echo "   make test-connections"
echo "   make test" 