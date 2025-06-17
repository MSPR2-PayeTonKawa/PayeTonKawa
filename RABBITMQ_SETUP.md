# Configuration RabbitMQ pour PayeTonKawa

## 🐰 Vue d'ensemble

Le système PayeTonKawa utilise RabbitMQ comme message broker pour permettre la communication asynchrone entre les microservices.

## 📋 Architecture des Événements

### Échanges et Routes
- **Exchange Principal**: `payetonkawa`
- **Type**: Topic Exchange
- **Routes disponibles**:
  - `customer.registered` - Nouveau client enregistré
  - `product.updated` - Produit mis à jour
  - `order.created` - Nouvelle commande créée

### Queues par Service
- `customers_service_queue` - Service Customers
- `products_service_queue` - Service Products  
- `orders_service_queue` - Service Orders

## 🚀 Installation et Démarrage

### 1. Démarrer RabbitMQ
```bash
docker-compose -f docker-compose-rabbitmq.yml up -d
```

### 2. Installer les dépendances PHP
Dans chaque microservice :
```bash
composer install
```

### 3. Démarrer les Event Listeners
Dans chaque service, lancez la commande :
```bash
php artisan events:listen
```

## 🔧 Variables d'Environnement

Ajoutez ces variables dans vos fichiers `.env` :

```env
RABBITMQ_HOST=PTK-MessageBroker
RABBITMQ_PORT=5672
RABBITMQ_USER=payetonkawa
RABBITMQ_PASSWORD=kawa2024!
RABBITMQ_VHOST=/
RABBITMQ_EXCHANGE=payetonkawa
RABBITMQ_QUEUE=nom_du_service
```

## 📡 Événements Disponibles

### CustomerRegisteredEvent
**Trigger**: Création d'un nouveau client
**Route**: `customer.registered`
**Listeners**: Orders Service

### ProductUpdatedEvent  
**Trigger**: Mise à jour d'un produit
**Route**: `product.updated`
**Listeners**: Orders Service

### OrderCreatedEvent
**Trigger**: Création d'une commande
**Route**: `order.created`
**Listeners**: Customers Service, Products Service

## 🌐 Interface Web RabbitMQ

Accédez à l'interface d'administration :
- **URL**: http://localhost:15672
- **Username**: payetonkawa
- **Password**: kawa2024!

## 📝 Utilisation dans le Code

### Publier un Événement
```php
use App\Events\CustomerRegisteredEvent;

$event = new CustomerRegisteredEvent();
$event->publish([
    'id' => $customer->id,
    'name' => $customer->name,
    'email' => $customer->email
]);
```

### Écouter des Événements
```php
use App\Services\EventListenerService;

$listener = new EventListenerService();
$listener->startListening();
```

## 🔄 Flux de Communication

1. **Client s'inscrit** → CustomerRegisteredEvent → Orders Service (mise à jour de la base client)
2. **Produit mis à jour** → ProductUpdatedEvent → Orders Service (synchronisation des prix)
3. **Commande créée** → OrderCreatedEvent → Products Service (mise à jour stock) + Customers Service (historique)

## 🛠️ Commandes Utiles

```bash
# Démarrer l'écoute d'événements
php artisan events:listen

# Vérifier l'état de RabbitMQ
docker logs PTK-MessageBroker

# Redémarrer RabbitMQ
docker-compose -f docker-compose-rabbitmq.yml restart

# Voir les queues actives
docker exec PTK-MessageBroker rabbitmqctl list_queues
```

## 🚨 Dépannage

### Problème de Connexion
- Vérifiez que RabbitMQ est démarré
- Contrôlez les variables d'environnement
- Vérifiez les logs : `docker logs PTK-MessageBroker`

### Messages Non Traités
- Vérifiez que les listeners sont actifs
- Contrôlez les logs Laravel
- Vérifiez l'interface web RabbitMQ pour les messages en attente 