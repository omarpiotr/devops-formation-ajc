
```bash
# initialiser le projet
terraform init
# faire un plan
terraform plan
# application : 
terraform apply

# Après modification
terraform plan
terraform apply --auto-approve

# suppression
terraform destroy --auto-approve

# alignement / formatage du code
terraform fmt

# connaitre les output existant
terraform output
terraform output nom_output_sauvegarde
# affiché un fichier sensible:
terraform output file_object.content
```