import psycopg2
import configparser 

class PGConnection(object):
	def __init__(self, userName, password):
		configurator = configparser.ConfigParser()
		configurator.read('postgresql.ini')

		self.connectionString = "host='" + configurator.get('DEFAULT', 'host') \
		  + "' port='" + configurator.get('DEFAULT', 'port') + "' dbname='" \
		  + configurator.get('DEFAULT', 'db') + "' user='" + userName \
		  + "' password='" + password + "'"
		
		try:
			tmpConnection = psycopg2.connect(self.connectionString)
			tmpConnection.close()
		except psycopg2.OperationalError as e:
			raise ValueError(format(e))
		
	def execute(self, queryString):
		try:
			connection = psycopg2.connect(self.connectionString)
			connection.autocommit = True
			cursor = connection.cursor()
			cursor.execute(queryString)
			connection.close()
		except psycopg2.Error as e:
			print (e.pgerror)
	
	def query(self, queryString):
		try:
			connection = psycopg2.connect(self.connectionString)
			connection.autocommit = True
			cursor = connection.cursor()
			cursor.execute(queryString)
			rows = cursor.fetchall()
			connection.close()
			return rows
		except psycopg2.Error as e:
			print (e.pgerror)
	
	def queryJson(self, queryString):
		try:
			connection = psycopg2.connect(self.connectionString)
			connection.autocommit = True
			cursor = connection.cursor()
			cursor.execute(queryString)
			rows = list(cursor.fetchall())
			connection.close()
			
			for result in rows:
				for element in result:
					return element
		
		except psycopg2.Error as e:
			print (e.pgerror)
			
	def prueba(self):
		print(self.connectionString)
