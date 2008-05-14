#!/bin/bash

if [ -f ~/.profile  ]; then
    source ~/.profile 
fi

if [ -f ~/.bash_profile  ]; then
    source ~/.bash_profile 
fi

ruby script/runner "Sequent::publisher"