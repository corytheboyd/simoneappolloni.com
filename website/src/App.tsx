import React, {useEffect} from 'react';

function App() {
    useEffect(() => {
        fetch('http://localhost:4567/data')
            .then((res) => res.text())
            .then((data) => console.log(data))
    }, [])

    return (
        <div className="flex flex-col items-center items-center space-y-5">
            <h1 className="text-4xl">Simone Appolloni</h1>

            <div>
                <p>Why the FUCK is this guy, coming in writing nearly 30,000 album reviews.</p>
                <p>Who does that?!</p>
                <p>We had to learn more...</p>
            </div>
        </div>
    );
}

export default App;
