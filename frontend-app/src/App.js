import React, { useEffect, useState } from 'react';

function App() {
    const [message, setMessage] = useState('');

    useEffect(() => {
        // Make an API call to the backend
        fetch('http://localhost:3003/api/hello')
        //console.log('Backend URL:', process.env.REACT_APP_BACKEND_URL); // Debug log
        //fetch(`${process.env.REACT_APP_BACKEND_URL}/api/hello`) 
        // didnt have enough time to debug why react sees REACT_APP_BACKEND_URL as  undefined 
            .then((response) => response.json())
            .then((data) => setMessage(data.message))
            .catch((error) => console.error('Error fetching data:', error));
    }, []);

    return (
        <div style={{ textAlign: 'center', marginTop: '50px' }}>
            <h1>Hello World!</h1>
            <p>Response from Backend: {message}</p>
        </div>
    );
}

export default App;
