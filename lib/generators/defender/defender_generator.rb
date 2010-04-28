require 'rails/generators'

class DefenderGenerator < Rails::Generators::NamedBase
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end

  def create_migration
    generate(:migration, "add_defender_to_#{table_name} defensio_signature:string spaminess:float spam:boolean")
  end
end
