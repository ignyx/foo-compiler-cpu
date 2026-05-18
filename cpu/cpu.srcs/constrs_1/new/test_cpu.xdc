#create_clock -period 10.000 -name CK -waveform {0.000 5.000} [get_ports CK]

# Cheat sheet :
# Switches:
# R2, T1, U1, W2, R3, T2, T3, V2, W13, W14, V15, W15, W17, W16, V16, V17
# Buttons:
# T18, W19, U18, T17, U17
# LEDs:
# L1, P1, N3, P3, U3, W3, V3, V13, V14, U14, U15, W18, V19, U19, E19, U16
#Horloge sur un bouton
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets NOM_HORLOGE]
#set_property -dict {PACKAGE_PIN NX IOSTANDARD LVCMOS33} [get_ports NOM_HORLOGE]
#Horloge avec un oscillateur
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { CLK } ]
create_clock -add -name sysclk_pin -period 10.00 -waveform { 0 5 } [get_ports { CLK } ]

# Signal binaire: RESET on right-most switch
set_property -dict {PACKAGE_PIN V17 IOSTANDARD LVCMOS33} [get_ports RST]

# Signal vectoriel: LSB is Left-most LED
set_property -dict {PACKAGE_PIN L1 IOSTANDARD LVCMOS33} [get_ports {Dout[0]}]
set_property -dict {PACKAGE_PIN P1 IOSTANDARD LVCMOS33} [get_ports {Dout[1]}]
set_property -dict {PACKAGE_PIN N3 IOSTANDARD LVCMOS33} [get_ports {Dout[2]}]
set_property -dict {PACKAGE_PIN P3 IOSTANDARD LVCMOS33} [get_ports {Dout[3]}]
set_property -dict {PACKAGE_PIN U3 IOSTANDARD LVCMOS33} [get_ports {Dout[4]}]
set_property -dict {PACKAGE_PIN W3 IOSTANDARD LVCMOS33} [get_ports {Dout[5]}]
set_property -dict {PACKAGE_PIN V3 IOSTANDARD LVCMOS33} [get_ports {Dout[6]}]
set_property -dict {PACKAGE_PIN v13 IOSTANDARD LVCMOS33} [get_ports {Dout[7]}]
