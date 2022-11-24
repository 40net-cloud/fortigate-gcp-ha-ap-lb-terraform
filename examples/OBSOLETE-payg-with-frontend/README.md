# Example: PAYG deployment in new VPCs&subnets with ELB frontend

*Note: this example presents an interim solution for creating frontends during deployment. It will be obsolete once ELB frontend support will be added to the module itself.*

This is a working example demonstrating how to add a frontend to the fgcp-ha-ap-lb module (here used to deploy a PAYG FortiGate 7.2 HA cluster into newly created subnets and VPCs). Mind that each subnet needs to be in a separate VPC (see [GCP Documentation](https://cloud.google.com/vpc/docs/create-use-multiple-interfaces#specifications)).

This example only adds the frontend to the ELB, you need to add the necessary configuration to the FortiGate afterwards to make it respond to health checks:

```
config system interface
    edit "port1"
        set secondary-IP enable
        config secondaryip
            edit 1
                set ip ELB_FRONTEND_IP 255.255.255.255
                set allowaccess probe-response
            next
        end
    next
end
```

ELB frontend IP can be used directly in FortiGate configuration as IPSec phase 1 local gateway, VIP external IP or IP Pool.
