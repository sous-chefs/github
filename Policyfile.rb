# frozen_string_literal: true

name 'github'

run_list 'test::default'
named_run_list :default, 'test::default'

cookbook 'github', path: '.'
cookbook 'test', path: 'test/fixtures/cookbooks/test'
