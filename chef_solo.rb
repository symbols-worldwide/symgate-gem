chefdir_local = File.join(File.expand_path(File.dirname(__FILE__)), '.chef')

cookbook_path [
  chefdir_local,
  File.join(chefdir_local, 'symboliser', 'test', 'fixtures', 'cookbooks')
]

cache_path 'c:/temp/cache'
role_path 'c:/temp/roles'
node_path 'c:/temp/nodes'
