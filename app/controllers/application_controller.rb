class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private
	
	def confirm_logged_in
		unless session[:user_id]
			redirect_to(access_login_path)
		end
	end

	def is_superuser
		user = AdminUser.find(session[:user_id])
		unless user.superuser?
			redirect_to(tests_path)
		end
	end

	class Sic
		def self.pass1 (source)
			source = source.split("\r\n")
			# Building 'OPTAB' from file
			optab=Hash.new
			file=File.open("OPTAB.txt")
			while line=file.gets
					line=line.split
					optab[line[1]]=line[0]
					end
			file.close

			# Building 'SYMTAB' from source code and writing intermediate file
			symtab=Hash.new
			start_check=false
			locctr=start_addr=0
			intermediate=File.open("intermediate.txt", "w")
				line=source.first.split
				if line[1]=='START'
				 locctr=start_addr=line[2]
					intermediate.puts("\t\t"+source.first)
					start_check=true
					source.delete(source.first)
				end
			if start_check
				source.each do |line_org|
					line=line_org.split
					if line[0]=='END'
						intermediate.puts(line_org)
						break;
					end
					intermediate.puts(locctr.rjust(4,"0")+"\t"+line_org)
					if optab[line[0]]
					 locctr=((locctr.to_i(16)+3).to_s(16)).to_s
					elsif line[0]=='WORD'
						locctr=((locctr.to_i(16)+3).to_s(16)).to_s
					elsif line[0]=='RESW'
						locctr=((locctr.to_i(16)+3*line[1].to_i).to_s(16)).to_s
					elsif line[0]=='RESB'
						locctr=((locctr.to_i(16)+line[1].to_i).to_s(16)).to_s
					elsif line[0]=='BYTE'
						if line[1][0]=='C'
							locctr=((locctr.to_i(16)+line[1].length-3).to_s(16)).to_s
						elsif line[1][0]=='X'
							locctr=((locctr.to_i(16)+(line[1].length-3)/2).to_s(16)).to_s
						end 
					elsif symtab[line[0]]
						puts 'duplicate symbol error'
				 else
					 symtab[line[0]]=locctr.rjust(4,"0")
					 if line[1]=='WORD'
						 locctr=((locctr.to_i(16)+3).to_s(16)).to_s
					 elsif line[1]=='RESW'
						 locctr=((locctr.to_i(16)+3*line[2].to_i).to_s(16)).to_s
						elsif line[1]=='RESB'
							locctr=((locctr.to_i(16)+line[2].to_i).to_s(16)).to_s
					 elsif line[1]=='BYTE'
						 if line[2][0]=='C'
							 locctr=((locctr.to_i(16)+line[2].length-3).to_s(16)).to_s
						 elsif line[2][0]=='X'
							 locctr=((locctr.to_i(16)+(line[2].length-3)/2).to_s(16)).to_s
						 end 
					 else
						 locctr=((locctr.to_i(16)+3).to_s(16)).to_s
					 end
				 end
			 end
			end
			intermediate.close
			# Writing end value of 'LOCCTR'
			locctr_file=File.open("LOCCTR.txt", "w")
			locctr_file.puts("LOCCTR\t"+locctr.to_s)
			locctr_file.close
			# Writing 'SYMTAB'
			sym_file=File.open("SYMTAB.txt", "w")
			symtab.each {|k,v| sym_file.puts("#{k}\t #{v}")}
			sym_file.close
		end

		def self.pass2 (id)
			# Loading OPTAB from OPTAB.txt
			optab=Hash.new
			op_file=File.open("OPTAB.txt")
			while line=op_file.gets
					line=line.split
					optab[line[1]]=line[0]
					end
			op_file.close

			# Loading SYMTAB from SYMTAB.txt generated during 'pass 1'
			symtab=Hash.new
			sym_file=File.open("SYMTAB.txt")
			while line=sym_file.gets
					line=line.split
					symtab[line[0]]=line[1]
					end
			sym_file.close

			# Reading 'intermedaite.txt' and writing 'intermediate_with_object_code.txt' and'object_program.txt'
			intermediate=File.open("intermediate.txt")
			locctr=File.open("LOCCTR.txt")
			object_prog=File.open("object_program.txt","w")

			# Writing Header record
			start_addr=0
			end_addr=0
			while line_org=intermediate.gets
				line=line_org.split
				if line[1]=='START'
					start_addr=line[2]
					end_addr=locctr.gets.split[1]
					size=((end_addr.to_i(16)-start_addr.to_i(16)).to_s(16)).to_s
					object_prog.puts "H^"+line[0].ljust(6,' ').upcase+"^"+start_addr.rjust(6,'0').upcase+"^"+size.rjust(6,'0').upcase
					Line.create(:program_id => id, :data => line_org.strip)
					break
				end
			end
			locctr.close

			# Writing Text Records
			text_record_length=0
			text_record_addr=start_addr
			text_record=''
			write_text_record = lambda { |object_prog,text_record_addr,text_record_length,text_record| object_prog.puts "T^"+text_record_addr.to_s.rjust(6,'0').upcase+"^"+((text_record_length/2).to_s(16)).to_s.rjust(2,'0').upcase+text_record.upcase }
			while line_org=intermediate.gets.upcase
				line=line_org.split
				if line[0]=='END'
					# Writing End Record
					write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
					object_prog.puts "E^"+start_addr.rjust(6,'0')
					Line.create( :program_id => id, :data => line_org)
					break
				end
				last=line[-1]
				slast=line[-2]
				if optab[last]
					if text_record_length+6>60
						write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
						text_record_length=6
						text_record_addr=line[0].rjust(6,'0')
						text_record=optab[last]+"0000"
					else
						if text_record_length!=0
							text_record+="^"
						else
							text_record_addr=line[0].rjust(6,'0')
						end
						text_record_length+=6
						text_record+=optab[last]+"0000"
					end
					Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip, :code => (optab[last]+"0000").upcase)
				
				else
					
					if symtab[last]
						if text_record_length+(optab[slast].length+symtab[last].length)>60
							write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
							text_record_length=(optab[slast].length+symtab[last].length)
							text_record_addr=line[0].rjust(6,'0')
							text_record="^"+optab[slast]+symtab[last]
						else
							if text_record_length!=0
								text_record+="^"
							else
								text_record_addr=line[0].rjust(6,'0')
							end
							text_record_length+=(optab[slast].length+symtab[last].length)
							text_record+="^"+optab[slast]+symtab[last]
						end
						Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip, :code => (optab[slast]+symtab[last]).upcase)
				
					elsif last.slice(-2,2)==',X'
						if text_record_length+(optab[slast].length+symtab[last.slice(0..-3)].length)>60
							write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
							text_record_length=(optab[slast].length+symtab[last.slice(0..-3)].length)
							text_record_addr=line[0].rjust(6,'0')
							text_record="^"+optab[slast]+((symtab[last.slice(0..-3)]).to_i(16)+2**15).to_s(16)
						else
							if text_record_length!=0
								text_record+="^"
							else
								text_record_addr=line[0].rjust(6,'0')
							end
							text_record_length+=(optab[slast].length+symtab[last.slice(0..-3)].length)
							text_record+=optab[slast]+((symtab[last.slice(0..-3)]).to_i(16)+2**15).to_s(16)
						end
						Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip, :code => (optab[slast]+((symtab[last.slice(0..-3)]).to_i(16)+2**15).to_s(16)).upcase)
				
					elsif slast=='WORD'
						if text_record_length+6>60
							write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
							text_record_length=6
							text_record_addr=line[0].rjust(6,'0')
							text_record="^"+last.to_i.to_s(16).rjust(6,'0')
						else
							if text_record_length!=0
								text_record+="^"
							else
								text_record_addr=line[0].rjust(6,'0')
							end
							text_record_length+=6
							text_record+=last.to_i.to_s(16).rjust(6,'0')
						end
						Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip, :code => (last.to_i.to_s(16).rjust(6,'0')).upcase)
				
					elsif slast=='RESW'
						if text_record_length!=0
							write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
							text_record=''
							text_record_length=0
						end
						Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip)
				
					elsif slast=='RESB'
						if text_record_length!=0
							write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
							text_record=''
							text_record_length=0
						end
						Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip)
					
					elsif slast=='BYTE'

						if last[0]=='C'
							if text_record_length+(last.slice(2..-2).unpack('H*')[0]).length>60
								write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
								text_record_length=(last.slice(2..-2).unpack('H*')[0]).length
								text_record_addr=line[0].rjust(6,'0')
								text_record="^"+last.slice(2..-2).unpack('H*')[0]
							else
								if text_record_length!=0
									text_record+="^"
								else
									text_record_addr=line[0].rjust(6,'0')
								end
								text_record_length+=(last.slice(2..-2).unpack('H*')[0]).length
								text_record+=last.slice(2..-2).unpack('H*')[0]
							end
							Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip, :code => (last.slice(2..-2).unpack('H*')[0]).upcase)
						
						elsif last[0]=='X'
							if text_record_length+(last.slice(2..-2)).length>60
								write_text_record.call(object_prog,text_record_addr,text_record_length,text_record)
								text_record_length=(last.slice(2..-2)).length
								text_record_addr=line[0].rjust(6,'0')
								text_record="^"+last.slice(2..-2)
							else
								if text_record_length!=0
									text_record+="^"
								else
									text_record_addr=line[0].rjust(6,'0')
								end
								text_record_length+=(last.slice(2..-2)).length
								text_record+=last.slice(2..-2)
							end
							Line.create( :program_id => id, :address => line_org.rstrip.split.first, :data => line_org.strip.slice(((line_org.index(" ")||line_org.index("\t"))+1)..-1).strip, :code => (last.slice(2..-2)).upcase)
						end 
					end
				end
			end
			object_prog.close
			intermediate.close
		end
	end
  
end
