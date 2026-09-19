cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(hmi_gauge
        VERSION 0.1.0 
        DESCRIPTION "simple human machine interface"
        LANGUAGES C)

target_sources(app PRIVATE src/main.c 
                           src/hmi_app.c
                           src/hmi_gauge.c)
