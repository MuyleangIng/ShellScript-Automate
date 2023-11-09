docker run --rm -v spring-volume:/volume -v /root:/backup alpine tar -czf /backup/volume-backup.tar.gz -C /volume .

tar -xzf volume-backup.tar.gz
