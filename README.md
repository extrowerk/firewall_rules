A simple (?) Python script to modularize my IPF firewall rules

I wanted to achieve a uniform style and consistent wording for my IPF firewall rules across my Solaris zones. Unfortunately, IPF does not support an `include` directive for modularizing firewall rules.

As an alternative, I decided to pre-generate the firewall rules using macro processing.

Initially, I tried to do this with `m4`, but the results were not entirely satisfactory.
