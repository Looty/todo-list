from flask import Flask, render_template, request, url_for, redirect
from flask.json import dumps
from flask_pymongo import PyMongo
import json
from bson import ObjectId
import datetime
import sys
from dotenv import load_dotenv
from os import environ

app = Flask(__name__)
load_dotenv()

ENV_MONGOURL = environ.get('MONGO_URL')
ENV_HOST = environ.get('HOST')
ENV_PORT = environ.get('PORT')
ENV_DEBUG = environ.get('DEBUG')
ENV_VERSION = environ.get('APP_VERSION')

app.config['MONGO_URI'] = ENV_MONGOURL
mongo = PyMongo(app)

todos = mongo.db.todos
@app.route('/')
def index():
    saved_todos = todos.find()
    return render_template('index.html', todos=saved_todos, version=ENV_VERSION)

@app.route('/add', methods=['POST'])
def add_todo():
    new_todo = request.form.get('new-todo')
    new_task_id = todos.insert_one({'text': new_todo, 'complete': False, 'created_at': datetime.datetime.now()})
    logger('added', new_task_id.inserted_id)
    return redirect(url_for('index'))

@app.route('/complete/<oid>')
def complete(oid):
    todo_item = todos.find_one({'_id': ObjectId(oid)})
    if todo_item['complete'] == True:
        todo_item['complete'] = False
    else:
        todo_item['complete'] = True
    todos.save(todo_item)
    logger('completed', oid)
    return redirect(url_for('index'))

@app.route('/task/<oid>')
def task_profile(oid):
    logger('viewed', oid)
    todo_item = todos.find_one({'_id': ObjectId(oid)})
    return json.dumps(todo_item, default=str)

@app.route('/delete/<oid>')
def deleteTask(oid):
    logger('deleted', oid)
    todos.delete_one({'_id': ObjectId(oid)})
    return redirect(url_for('index'))

def logger(action, oid):
    log = {
        'action': action,
        'taskId': str(oid)
    }
    print(log, file=sys.stdout)

if __name__=='__main__':
    if ENV_DEBUG == 'true':
        app.run(debug=True, host=ENV_HOST, port=ENV_PORT)
    else:
        app.run(host=ENV_HOST, port=ENV_PORT)