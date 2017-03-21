class CreateTests < ActiveRecord::Migration[5.0]
  
	def change
    create_table :tests do |t|
    	t.references :program
    	t.references :admin_user
    	t.integer :score, :default => 0
    	t.timestamps null: false
    end
  end
  
end
