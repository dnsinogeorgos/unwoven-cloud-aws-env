output "buckets" {
  value = {
    main = module.bucket_main
    dr   = module.bucket_dr
  }
}
