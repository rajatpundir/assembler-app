class CreateAdminUsers < ActiveRecord::Migration[5.0]
  
	def change
    create_table :admin_users do |t|
    	t.string :first_name
    	t.string :last_name
    	t.string :section
    	t.integer :roll_number
        t.integer :year
    	t.string :email
    	t.string :username,:null => false, :unique => true
    	t.string :password_digest
        t.boolean :superuser, :default => false
    	t.timestamps null: false
    end
  end
  
end
