#! /usr/bin/env ruby
# encoding: UTF-8
require 'bootstrap-sass'
require 'ruby-prof'
require 'pry'


files_to_compile = [
  'bare.css.scss',
  'panel_one_class.css.scss',
  'panel_long_id_list.css.scss',
  'panel_long_class_list.css.scss',
  'panel_long_child_id.css.scss',
  'buttons-extend.css.scss',
  'buttons-mixin.css.scss'
]

other_files_to_compile = Dir.glob('others/*.scss')


class RubyProf::FlatPrinter
  def print_header(thread)
    @output << "   Size   Lines   Time\n"
  end
  def print_footer(thread)
  end
end

print_header = true
RubyProf.measure_mode = RubyProf::WALL_TIME
(files_to_compile + other_files_to_compile).each do |file|
  output_file = File.basename(file,'.scss')
  css = ""
  if File.exist?(output_file) && (File.mtime(output_file) > File.mtime(file))
    next
  end
  result = RubyProf.profile {
    css = Sass::Engine.for_file(file, {style: :compact,load_paths: [Bootstrap.stylesheets_path, '.']}).render
  }
  if output_file != file
    File.open(output_file,'w') {|f| f.write css }
  end
  result.eliminate_methods!([/^(?!Global)/])
  output_data = []
  printer = RubyProf::FlatPrinter.new(result)
  printer.print(output_data, :min_percent => 0.0)
  output_data.each do |line|
    if line =~ /\s[0-9]/
      data = line.tr_s(' ',' ').split(' ')
      puts " #{css.length}    #{css.lines.count}  #{data[2]} - #{file}"
    elsif print_header
      puts line
      print_header = false
    end
  end
end
