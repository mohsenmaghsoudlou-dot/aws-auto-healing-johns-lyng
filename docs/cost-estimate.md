# Cost estimate

The proposed lower-cost configuration is **Mumbai (ap-south-1) with two
t4g.nano instances**, estimated at **AUD 48.47/month in fixed costs**.
AWS was selected because its estimated cost was lower than the Azure
configuration evaluated for this exercise; the configurations were not identical.

Assumptions: 730 hours/month, Linux On-Demand pricing, USD 1 = AUD 1.60,
one ALB across two Availability Zones, two public IPv4 addresses and two
8 GiB gp3 disks. Estimates exclude GST and promotional credits.

## Proposed monthly cost: Mumbai

| Component | Quantity and USD rate | AUD/month |
| --- | --- | ---: |
| Two t4g.nano instances | 2 × 730 hours × 0.0028 | 6.54 |
| Application Load Balancer | 730 hours × 0.0239 | 27.92 |
| Two public IPv4 addresses | 2 × 730 hours × 0.005 | 11.68 |
| gp3 root storage | 16 GB-month × 0.0912 | 2.33 |
| S3 gateway endpoint | No additional endpoint charge | 0.00 |
| **Fixed total** | Calculated before rounding | **48.47** |

ALB usage is additional: an average of 0.1–0.4 LCU at USD 0.008/LCU-hour
brings the estimate to **AUD 49.41–52.21/month**, before internet data transfer
and GST. These are illustrative traffic assumptions, not measured usage.
Temporary replacement capacity and optional services are excluded.
**The AUD 20/month target is not met.**

## Proposed design versus test deployment

| Configuration | Fixed AUD/month | Status |
| --- | ---: | --- |
| Mumbai: two t4g.nano | **48.47** | Costed proposal; not deployed or tested |
| Sydney: two t4g.nano | 55.95 | Like-for-like regional cost comparison |
| Sydney: two t4g.micro | 68.33 | Deployed and tested |

Testing used Sydney with t4g.micro because the test account's Free Tier plan
rejected t4g.nano launches. This account restriction does not make nano
infeasible for other accounts. The existing deployment remains in Sydney.
Mumbai saves AUD 7.48/month compared with the same nano design in Sydney;
its use assumes Australian data residency and latency are outside this
exercise's scope.

Rates checked in September 2026: [Mumbai EC2 and EBS](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/ap-south-1/index.csv),
[Mumbai ALB](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AWSELB/current/ap-south-1/index.json),
[Sydney EC2 and EBS](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/ap-southeast-2/index.csv),
[Sydney ALB](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AWSELB/current/ap-southeast-2/index.json)
and [public IPv4](https://aws.amazon.com/vpc/pricing/).
The evaluated Azure alternative was approximately AUD 76.32/month fixed
(two B1s VMs, Standard Load Balancer, one public IPv4 and two 32 GiB E4 LRS
disks); sizing and service differences prevent an exact equivalence.
[Selected Azure pricing records](evidence/azure-price-selection.json) are retained.
