# EC2 pricing

###### price per set of 3 nodes in USD for eu-central-1
```
t3.medium   105.12  2t  4g  <- best arm VFM small clusters
t4g.medium   84.096 2c  4g  <- best arm VFM small clusters
m6g.medium   84.315 1c  4g
c6g.medium   84.972 1c  2g
r6g.medium  110.376 1c  8g

# burstable
t3.large    210.24  2t  8g
t4g.large   168.192 2c  8g

# general purpose
m5.large    251.85  2t  8g
m5n.large   308.79  2t  8g
m5zn.large  433.401 2t  8g <- best single core performance
m6i.large   251.85  2t  8g <- best x86 VFM
m6g.large   201.48  2c  8g <- best arm VFM

# compute optimized
c5.large    212.43  2t  4g
c5n.large   269.37  2t  4g
c6g.large   169.944 2c  4g
c6gn.large  ???.??  2c  4g

# memory optimized <- these are ideal for elasticsearch workloads
r5.large    332.88  2t  16g
r5b.large   389.82  2t  16g <- best EBS performance
r5n.large   389.82  2t  16g
r6g.large   266.304 2c  16g
```
