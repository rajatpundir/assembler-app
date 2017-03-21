class CreatePrograms < ActiveRecord::Migration[5.0]
  
	def change
  	create_table :programs do |t|
  		t.integer :position
    	t.string :name,:null => false, :unique => true
    	t.text :source, :default => ""
      t.text :object_program, :default => ""
    	t.boolean :visible, :default => false
      t.boolean :addressing, :default => false
  		t.timestamps null: false
  	end
  end
  
end
