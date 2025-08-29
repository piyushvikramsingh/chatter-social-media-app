# AWS Deployment Guide for Chatter Social Media App

This guide provides comprehensive instructions for deploying the Chatter Flutter app and Laravel backend on AWS infrastructure.

## 🚀 AWS Services Architecture

### **Core Infrastructure**
- **EC2**: Laravel backend hosting
- **RDS**: MySQL database (Multi-AZ for production)
- **S3**: File storage (images, videos, audio)
- **CloudFront**: CDN for media delivery
- **Route 53**: DNS management
- **Application Load Balancer**: Load balancing and SSL termination
- **Auto Scaling Groups**: High availability and scaling

### **Optional Services**
- **ElastiCache**: Redis for session/cache management
- **SES**: Email notifications
- **SNS**: Push notifications
- **CloudWatch**: Monitoring and logging
- **IAM**: Security and access management

## 📋 Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
3. **Domain name** (optional but recommended)
4. **SSL Certificate** (Let's Encrypt or AWS Certificate Manager)

## 🛠️ Step-by-Step Deployment

### **1. Database Setup (RDS)**

```bash
# Create RDS MySQL instance
aws rds create-db-instance \
    --db-instance-identifier chatter-prod-db \
    --db-instance-class db.t3.micro \
    --engine mysql \
    --engine-version 8.0.35 \
    --master-username admin \
    --master-user-password YourSecurePassword123! \
    --allocated-storage 20 \
    --vpc-security-group-ids sg-xxxxxxxxx \
    --db-subnet-group-name default \
    --backup-retention-period 7 \
    --multi-az \
    --storage-encrypted
```

### **2. S3 Bucket Setup**

```bash
# Create S3 bucket for file storage
aws s3 mb s3://chatter-app-storage-prod --region us-east-1

# Configure bucket policy for public read access to media files
aws s3api put-bucket-policy --bucket chatter-app-storage-prod --policy '{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::chatter-app-storage-prod/public/*"
    }
  ]
}'

# Enable CORS for mobile app access
aws s3api put-bucket-cors --bucket chatter-app-storage-prod --cors-configuration '{
  "CORSRules": [
    {
      "AllowedOrigins": ["*"],
      "AllowedMethods": ["GET", "PUT", "POST", "DELETE"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3000
    }
  ]
}'
```

### **3. EC2 Instance Setup**

```bash
# Launch EC2 instance (Ubuntu 22.04 LTS)
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t3.small \
    --key-name your-key-pair \
    --security-group-ids sg-xxxxxxxxx \
    --subnet-id subnet-xxxxxxxxx \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=chatter-backend-prod}]'
```

### **4. Server Configuration**

#### **Install Required Software**

```bash
# Connect to EC2 instance
ssh -i your-key.pem ubuntu@your-ec2-public-ip

# Update system
sudo apt update && sudo apt upgrade -y

# Install PHP 8.2 and required extensions
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt update
sudo apt install -y php8.2 php8.2-fpm php8.2-mysql php8.2-xml php8.2-curl php8.2-mbstring php8.2-zip php8.2-gd php8.2-bcmath php8.2-json php8.2-intl

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Nginx
sudo apt install -y nginx

# Install Node.js (for building assets)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

#### **Deploy Laravel Application**

```bash
# Clone or upload your application
cd /var/www/
sudo git clone your-repo-url chatter-backend
sudo chown -R www-data:www-data chatter-backend
cd chatter-backend

# Install dependencies
composer install --optimize-autoloader --no-dev
npm install && npm run production

# Set up environment
sudo cp .env.example .env
sudo nano .env  # Configure production settings

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Set proper permissions
sudo chmod -R 755 /var/www/chatter-backend
sudo chmod -R 775 /var/www/chatter-backend/storage
sudo chmod -R 775 /var/www/chatter-backend/bootstrap/cache
```

### **5. Environment Configuration**

Update `.env` file with production values:

```env
APP_NAME=Chatter
APP_ENV=production
APP_DEBUG=false
APP_URL=https://your-domain.com

# Database (RDS)
DB_CONNECTION=mysql
DB_HOST=chatter-prod-db.xxxxxxxxx.us-east-1.rds.amazonaws.com
DB_PORT=3306
DB_DATABASE=chatter_database
DB_USERNAME=admin
DB_PASSWORD=YourSecurePassword123!

# AWS S3 Configuration
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=chatter-app-storage-prod
ITEM_BASE_URL=https://chatter-app-storage-prod.s3.amazonaws.com/

# Firebase Configuration (for push notifications)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-...@your-project.iam.gserviceaccount.com

# Agora Configuration (for video calls)
AGORA_APP_ID=your-agora-app-id
AGORA_APP_CERT=your-agora-certificate
```

### **6. Nginx Configuration**

```nginx
# /etc/nginx/sites-available/chatter-backend
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    root /var/www/chatter-backend/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }

    # Handle large file uploads
    client_max_body_size 100M;
}
```

### **7. SSL Setup with Let's Encrypt**

```bash
# Install Certbot
sudo apt install -y certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal
sudo systemctl enable certbot.timer
```

### **8. Application Load Balancer (Optional)**

For high availability, set up an Application Load Balancer:

1. Create target group for EC2 instances
2. Configure health checks
3. Set up SSL termination
4. Configure Auto Scaling Group

## 📱 Flutter App Configuration

Update the Flutter app to use your AWS backend:

### **Update API URLs**

```dart
// lib/utilities/const.dart
class ApiConstants {
  static const String baseUrl = 'https://your-domain.com/api/';
  static const String mediaBaseUrl = 'https://chatter-app-storage-prod.s3.amazonaws.com/';
}
```

### **Build for Production**

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔐 Security Checklist

### **Laravel Backend Security**
- [ ] Set `APP_DEBUG=false` in production
- [ ] Use strong database passwords
- [ ] Configure proper CORS settings
- [ ] Set up rate limiting
- [ ] Enable Laravel's CSRF protection
- [ ] Use HTTPS everywhere
- [ ] Regular security updates

### **AWS Security**
- [ ] Use IAM roles with least privilege
- [ ] Enable VPC security groups
- [ ] Configure S3 bucket policies properly
- [ ] Enable CloudTrail logging
- [ ] Set up AWS Config rules
- [ ] Use AWS Secrets Manager for sensitive data

## 📊 Monitoring & Logging

### **CloudWatch Setup**
```bash
# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
sudo rpm -U ./amazon-cloudwatch-agent.rpm
```

### **Laravel Logging**
Configure Laravel to send logs to CloudWatch:

```php
// config/logging.php
'cloudwatch' => [
    'driver' => 'custom',
    'via' => App\Logging\CloudWatchLoggerFactory::class,
    'level' => 'debug',
],
```

## 🚀 Deployment Automation

### **CI/CD Pipeline (GitHub Actions)**

```yaml
# .github/workflows/deploy.yml
name: Deploy to AWS

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Deploy to EC2
      uses: appleboy/ssh-action@v0.1.5
      with:
        host: ${{ secrets.EC2_HOST }}
        username: ubuntu
        key: ${{ secrets.EC2_SSH_KEY }}
        script: |
          cd /var/www/chatter-backend
          git pull origin main
          composer install --no-dev --optimize-autoloader
          php artisan migrate --force
          php artisan config:cache
          php artisan route:cache
          php artisan view:cache
          sudo systemctl reload nginx
```

## 💰 Cost Optimization

### **Estimated Monthly Costs (USD)**
- **EC2 t3.small**: ~$15-20
- **RDS db.t3.micro**: ~$12-15
- **S3 Storage**: ~$5-20 (depending on usage)
- **CloudFront**: ~$1-10
- **Route 53**: ~$0.50
- **Data Transfer**: ~$5-20

**Total**: ~$40-85/month for small to medium scale

### **Optimization Tips**
- Use S3 Intelligent Tiering
- Configure CloudFront caching
- Set up Auto Scaling based on demand
- Use Reserved Instances for predictable workloads
- Monitor costs with AWS Cost Explorer

## 🆘 Troubleshooting

### **Common Issues**

1. **Database Connection Issues**
   - Check RDS security groups
   - Verify database credentials
   - Ensure VPC configuration

2. **File Upload Issues**
   - Check S3 permissions
   - Verify CORS configuration
   - Check PHP upload limits

3. **Performance Issues**
   - Enable OpCache for PHP
   - Configure Redis for sessions
   - Optimize database queries

## 📞 Support

For deployment assistance:
- AWS Support (if you have a support plan)
- Laravel Documentation
- Flutter Documentation
- Community forums and Stack Overflow

---

**Note**: This guide provides a foundation for AWS deployment. Adjust configurations based on your specific requirements, scale, and security needs.
