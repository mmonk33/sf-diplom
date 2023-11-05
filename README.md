  ```
  terraform apply

  export TF_VAR_yandex_cloud_token=$(yc iam create-token)
  export TF_VAR_yandex_cloud_id=$(yc config get cloud-id)
  export TF_VAR_yandex_folder_id=$(yc config get folder-id)

    token     = var.yandex_cloud_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id

  YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)export YC_FOLDER_ID=$(yc config get folder-id)




