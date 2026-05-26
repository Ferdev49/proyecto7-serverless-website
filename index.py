def handler(event, context):
    """
    Lambda@Edge function for CloudFront viewer request
    Adds custom headers and handles requests
    """
    request = event['Records'][0]['cf']['request']
    headers = request['headers']
    
    # Add custom headers
    headers['x-powered-by'] = [{
        'key': 'X-Powered-By',
        'value': 'Terraform + Serverless'
    }]
    
    headers['x-custom-header'] = [{
        'key': 'X-Custom-Header',
        'value': 'Proyecto7'
    }]
    
    return request