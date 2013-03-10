#!/usr/bin/python

import sys
import re
import codecs

class SqlConverter:
	#states
	start = 1
	intable = 2
	infunc = 4
	funchead = 8
	funcbody = 16
	comment = 32
	untilgo = 64
	def __init__(self,fname):
		self.outfile = codecs.getwriter('utf8')(sys.stdout)
		self.i = codecs.open(fname,'r', encoding='utf-8')
		#self.outfile2 = codecs.open(fname+'out', 'w', encoding='utf-8')
		self.cases = [
			(self.start,r'SET',self.h_comment),
			(self.start,r'^--',self.h_doxcomment),
			(self.start,r'EXEC',self.h_untilgo),
			(self.start,r'^USE',self.h_untilgo),
			(self.start,r'^CREATE DATABASE',self.h_untilgo),
			(self.start,r'^CREATE TRIGGER',self.h_untilgo),
			(self.start,r'^ALTER DATABASE',self.h_untilgo),
			(self.start,r'^IF',self.h_untilgo),
			(self.start,r'^CREATE USER',self.h_untilgo),
			(self.start,r'^CREATE .*INDEX',self.h_untilgo),
			(self.start,r'alter table',self.h_untilgo),
			(self.start,r'create view',self.h_untilgo),
			(self.start,r'/\*.*\*/',self.h_write),
			(self.start,u'\ufeff',self.h_none),
			(self.intable|self.funcbody,r'GO',self.h_funcbodyend),
			(self.intable,r'\[([^]]*)\].*\[([^]]*)\].*',self.h_structfield),
			(self.start|self.untilgo,r'GO',self.h_go),
			(self.funcbody,r'.',self.h_rest),
			(self.start,r'CREATE TABLE.*\[(.*)\].*',self.h_create_table),
			(self.start|self.funcbody|self.comment,r'^\s*$',self.h_write),
			(self.comment,r'\*/',self.h_commentend),
			(self.comment,'.',self.h_write),
			(self.intable|self.untilgo,r'.*',self.h_rest),
			(self.start,r'CREATE FUNCTION.*\.\[(.*)\].*',self.h_function),
			(self.start,r'create proc.*\.\[(.*)\].*',self.h_function),
			(self.funchead,r'AS',self.h_funcheadend),
			(self.start,r'/\*',self.h_commentstart),
		]
		self.state = self.start

	def write(self,string):
		self.outfile.write(string)
		#self.outfile2.write(string)
	def h_untilgo(self,match):
		self.h_comment()
		self.state=self.untilgo

	def h_go(self,match):
		self.h_comment()
		self.state=self.start

	def h_function(self,match):
		funcname = match.group(1)
		self.h_comment()
		nextlines = []
		while self.next():
			m=re.match(r'@(\S*) ([^,]*).*',self.cur.strip(),re.I)
			if m:
				nextlines.append("  %s %s,\t//%s"%(m.group(2),m.group(1),self.cur))
			elif re.match(r'^\s*$',self.cur.strip()):
				nextlines.append(self.cur)
			elif re.match(r'^\s*\(\s*$',self.cur.strip(),re.I):
				nextlines.append("//"+self.cur)
			else:
				m=re.match(r'AS',self.cur.strip(),re.I)
				if m:
					self.state=self.funcbody
					self.write("  %s %s (\t//%s"%('void',funcname,self.cur))
					nextlines.append(") {\n")
					break
				else:
					nextlines.append("//"+self.cur)
					break
		while self.next():
			if self.state == self.funcbody:
				break
			m=re.match(r'RETURNS (.*)',self.cur.strip(),re.I)
			if m:
				self.write("  %s %s (\t//%s"%(m.group(1),funcname,self.cur))
				self.state=self.funchead
				break
			else:
				m=re.match(r'AS',self.cur.strip(),re.I)
				if m:
					self.state=self.funcbody
					self.write("  %s %s (\t//%s"%('void',funcname,self.cur))
					nextlines.append(") {")
					break
			nextlines.append("//%s"%self.cur)
		self.write("".join(nextlines))

	def h_commentstart(self,match):
		self.write(self.cur)
		self.state=self.comment

	def h_commentend(self,match):
		self.write(self.cur)
		self.state=self.start

	def h_funcheadend(self,match):
		self.write(') {\t//'+self.cur)
		self.state = self.funcbody

	def h_create_table(self,match):
		self.write("struct %s {\t//%s"%(match.group(1),self.cur))
		self.state = 2

	def h_rest(self,match=None):
		self.write("\t\t//%s"%(self.cur))

	def h_structfield(self,match=None):
		self.write("\t %s %s;\t//%s"%(match.group(2),match.group(1),self.cur))

	def h_none(self,match=None):
		self.write('\n')

	def h_funcbodyend(self,match=None):
		self.write('};')
		self.state = self.start
		self.h_comment()

	def h_comment(self,match=None):
		self.write('//'+self.cur)

	def h_doxcomment(self,match=None):
		self.write('///'+self.cur)

	def h_writebad(self,match=None):
		self.write('?"%s"(%u)%s\n'%(self.cur.strip(),self.state,self.cur.strip().encode('utf-8').encode('hex')))

	def h_write(self,match=None):
		self.write(self.cur)
		#self.write("%u%s"%(self.state,self.cur))

	def next(self):
		self.cur = self.i.next()
		self.cur = re.sub("FLOAT","float",self.cur)
		return self.cur

	def current(self):
		return self.cur

	def __getattr__(self,name):
		return getattr(self.i,name)

	def run(self):
		try:
			while self.next():
				#self.write("%u"%self.state)
				for (state,test,emitter) in self.cases:
					if(self.state & state):
						match = re.match(test,self.cur.strip(),re.I)
						if match:
							emitter(match)
							break
				else:
					self.h_writebad()
		except StopIteration:
			pass
		

