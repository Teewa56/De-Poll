import React from "react";

interface ErrorBoundaryProps{
    children: React.ReactNode;
}

interface ErrorBoundaryState{
    hasError: boolean;
}

export default class ErrorBoundary extends React.Component<ErrorBoundaryProps, ErrorBoundaryState>{
    constructor(props: ErrorBoundaryProps){
        super(props);
        this.state = { hasError: false };
    }

    static getDerivedStateFromError(): ErrorBoundaryState{
        return {hasError : true};
    }

    componentDidCatch(error: Error, errorInfo: React.ErrorInfo): void {
        console.log(error, errorInfo);
    }

    handleReload = () => {
        this.setState({hasError: false});
        window.location.reload();
    }

    render(){
        if(this.state.hasError){
            return(
                <div className="flex items-center justify-between h-screen">
                    <div className="w-1/2">
                        <p className="text-xl font-semibold">An error occured, try reloading this page or check your internet connection</p>
                        <button
                            className="px-6 py-2 bg-blue-600 textxl text-gray-400 rounded-3xl shadow-lg"
                            onClick={this.handleReload}
                        >
                            <p>Reload</p>
                        </button>
                    </div>
                </div>
            )
        }
        return this.props.children;
    }
}