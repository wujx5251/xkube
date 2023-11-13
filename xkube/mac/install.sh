#!/bin/bash

function install() {
  \cp kubectl /usr/local/bin
  \cp xkube /usr/local/bin
  
  mkdir ~/.kube 2>/dev/null
  \cp ../config ~/.kube/config
}

install