dev:
	cd src && \
	echo "http://localhost:8080" && \
	python -m SimpleHTTPServer 8080

deploy:
	aws s3 sync src s3://$(shell cd terraform && terraform output -raw website_bucket_name)
	cd terraform && terraform output S3_Public_URL

infra:
	cd terraform && terraform apply

destroy:
	cd terraform && terraform destroy
