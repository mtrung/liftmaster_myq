#!/bin/bash

module=liftmaster_myq

gem build $module.gemspec
sudo gem install $module-0.1.2.gem
test/test.rb
